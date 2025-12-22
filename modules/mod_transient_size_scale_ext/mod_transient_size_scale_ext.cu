
#define ROCKY_CUDA_API
#include <rocky20/api/rocky_api.h>
#include <rocky20/api/device/api_backend.hpp>

struct scale_parameters
{
    double scale_point_A;
    double scale_point_B;
    double scale_point_C;
    double scale_point_D;
    double scale_size_factor_B;
    double scale_size_factor_C;
    double scale_size_factor_D;
};

struct ModuleData
{
    int n_groups;
    scale_parameters *scale_parameter;
    int initial_volume_index;
    double init_vol_factor;
};

ROCKY_PLUGIN("Mod Transient Size Scale Ext", "1.0.0")

ROCKY_PLUGIN_CONFIGURE(input_data, module_data)
{
    auto data = new ModuleData();
    auto model = input_data.get_model();
    
    data->n_groups = input_data.get_number_particle_groups();
    data->scale_parameter = new scale_parameters[data->n_groups];

    for (int i = 0; i < data->n_groups; ++i)
    {
        auto group_data = input_data.get_particle_group_data(i);
        auto &group = data->scale_parameter[i];
        
        group.scale_point_A = group_data.get_double("scale_point_A");
        group.scale_point_B = group_data.get_double("scale_point_B");
        group.scale_point_C = group_data.get_double("scale_point_C");
        group.scale_point_D = group_data.get_double("scale_point_D");

        group.scale_size_factor_B = group_data.get_double("scale_size_factor_B");
        group.scale_size_factor_C = group_data.get_double("scale_size_factor_C");
        group.scale_size_factor_D = group_data.get_double("scale_size_factor_D");
    }
    module_data = static_cast<void*>(data);
}

ROCKY_PLUGIN_SETUP(model, module_data)
{
    auto data = static_cast<ModuleData*>(module_data);

    auto particle_scalars = model.get_particle_scalars();
    // This provides the volume of the particle when the size scale is equal to 1. 
    // It is used for model calculation purposes.
    data->initial_volume_index = particle_scalars.add("Initial Volume", "m3");
    data->init_vol_factor = particle_scalars.add("Initial Volume Factor", "-");
}

ROCKY_PLUGIN_NON_DIMENSIONALIZE(model, module_data)
{
    auto data = static_cast<ModuleData *>(module_data);

    double volume_factor = pow(model.get_length_factor(), 3);
    model.get_particle_scalars().set_dimension(data->initial_volume_index, volume_factor);

    for (int i = 0; i < data->n_groups; ++i)
    {
        auto &group = data->scale_parameter[i];       
        group.scale_point_A /= model.get_length_factor();
        group.scale_point_B /= model.get_length_factor();
        group.scale_point_C /= model.get_length_factor();
        group.scale_point_D /= model.get_length_factor();
    }
}

ROCKY_PLUGIN_TEAR_DOWN(model, module_data)
{
    ModuleData* data = static_cast<ModuleData *>(module_data);
    if (data->scale_parameter)
        delete[] data->scale_parameter;
    delete data;
}

ROCKY_PLUGIN_INITIALIZE_CUDA(model, host_data, device_id, _device_data)
{
    auto h_data = static_cast<ModuleData *>(host_data);
    auto d_data = *h_data;

    scale_parameters* d_group_parameter = nullptr;
    int size = h_data->n_groups;
    CUDA_MALLOC_TYPE(d_group_parameter, size, scale_parameters);
    CUDA_COPY_H2D(d_group_parameter, h_data->scale_parameter, size);
    d_data.scale_parameter = d_group_parameter;

    ModuleData *device_data = nullptr;
    CUDA_MALLOC_TYPE(device_data, 1,ModuleData);
    CUDA_COPY_H2D(device_data, &d_data, 1);
    _device_data = static_cast<void *>(device_data);
}

ROCKY_PLUGIN_TEAR_DOWN_CUDA(model, device_id, device_data)
{
    auto d_data = static_cast<ModuleData*>(device_data);
    ModuleData data_ptrs;
    CUDA_COPY_D2H(&data_ptrs, d_data, 1);
    CUDA_FREE(data_ptrs.scale_parameter);
    CUDA_FREE(d_data);
}


ROCKY_PLUGIN_PRE_MOVE_PARTICLES(model, particle, module_data)
{
    auto data = static_cast<ModuleData *>(module_data);
    
    int pgindex = particle.get_particle_group_index();

    auto &group = data->scale_parameter[pgindex];
    
	auto scalars = particle.get_scalars();
    
	double particle_volume = particle.get_volume();
	double volume_increment_old = scalars.get_volume_increment();
    double3 position_p = particle.get_centroid_position();

    double size_scale_factor = 1.0;
    double n_factor = 1.0;

    if (position_p.z <= group.scale_point_A)
    {
        size_scale_factor = 1.0;
    }
    else if ((group.scale_point_A < position_p.z) && (position_p.z <= group.scale_point_B))
    {
        n_factor = (group.scale_size_factor_B - 1.0) / (group.scale_point_B - group.scale_point_A);
        size_scale_factor = 1.0 + (position_p.z - group.scale_point_A) * n_factor;
    }
    else if ((group.scale_point_B < position_p.z) && (position_p.z <= group.scale_point_C))
    {
        n_factor = (group.scale_size_factor_C - group.scale_size_factor_B) / (group.scale_point_C - group.scale_point_B);
        size_scale_factor = group.scale_size_factor_B + (position_p.z - group.scale_point_B) * n_factor;
    }
    else if ((group.scale_point_C < position_p.z) && (position_p.z <= group.scale_point_D))
    {
        n_factor = (group.scale_size_factor_D - group.scale_size_factor_C) / (group.scale_point_D - group.scale_point_C);
        size_scale_factor = group.scale_size_factor_C + (position_p.z - group.scale_point_C) * n_factor;
    }
    else if (group.scale_point_D < position_p.z)
    {
        size_scale_factor = group.scale_size_factor_D;
    }    
    
    double volume_scale_factor = pow(size_scale_factor, 3);
    double initial_volume = 0.0;
    double init_factor = 1.0;
    
    /* INIT */ 
    if ((position_p.z <= group.scale_point_A) && (0.0 < volume_increment_old))
    {
        initial_volume = particle_volume;
        scalars.set_scalar(data->initial_volume_index, initial_volume);
        scalars.set_scalar(data->init_vol_factor, 1.0);
        scalars.set_volume_increment(0.0);
        volume_increment_old = 0.0;
    }
    else if ((group.scale_point_A < position_p.z) && (0.0 < volume_increment_old))
    {
        initial_volume = (particle_volume / volume_scale_factor);
        scalars.set_scalar(data->initial_volume_index, initial_volume);
        scalars.set_scalar(data->init_vol_factor, volume_scale_factor);
        scalars.set_volume_increment(0.0);
        volume_increment_old = 0.0;
    }    
    
    init_factor = scalars.get_scalar(data->init_vol_factor);
    initial_volume = scalars.get_scalar(data->initial_volume_index);

	double current_volume = volume_scale_factor * initial_volume ;
	double volume_increment_new = current_volume - initial_volume * init_factor;

	auto material = particle.get_material();
	double particle_density = material.get_density();
	double mass_increment = 0.0; 

    if (volume_increment_new < volume_increment_old)
    {
        scalars.set_volume_increment(volume_increment_new);
        mass_increment = particle_density * volume_increment_new;
    }
    else
    {
        scalars.set_volume_increment(volume_increment_old);
        mass_increment = particle_density * volume_increment_old;
    }

    scalars.set_mass_increment(mass_increment);

}
ROCKY_PLUGIN_PRE_MOVE_PARTICLES_END()


ROCKY_PLUGIN_END

