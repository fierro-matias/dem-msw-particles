#define ROCKY_CUDA_API
#include <rocky20/api/rocky_api.h>
#include <rocky20/api/device/api_backend.hpp>
#include <rocky20/api/rocky_contact_api.hpp>

struct ModuleData
{
    double* scale_point_A;
    double* mod_adhesive_distance;
    double* initial_stiffness_coefficient;
    double* final_stiffness_coefficient;
    int pp_index;
    int pt_index;
};

ROCKY_PLUGIN("Mod Adhesion Off", "1.0.0")

ROCKY_PLUGIN_CONFIGURE(input_data, module_data)
{
    auto data = new ModuleData();

    int n_material_interactions = input_data.get_number_material_interactions();
    
    data->scale_point_A = new double[n_material_interactions];
    data->mod_adhesive_distance = new double[n_material_interactions];
    data->initial_stiffness_coefficient = new double[n_material_interactions];
    data->final_stiffness_coefficient = new double[n_material_interactions];

    for (int i = 0; i < n_material_interactions; ++i)
    {
        auto material_interaction_data = input_data.get_material_interaction(i);

        data->scale_point_A[i] = material_interaction_data.get_double("scale_point_A");
        data->mod_adhesive_distance[i] = material_interaction_data.get_double("mod_adhesive_distance");
        data->initial_stiffness_coefficient[i] = material_interaction_data.get_double("initial_stiffness_coefficient");
        data->final_stiffness_coefficient[i] = material_interaction_data.get_double("final_stiffness_coefficient");
    }

    module_data = static_cast<void*>(data);
}


ROCKY_PLUGIN_SETUP(model, module_data)
{
    auto data = static_cast<ModuleData*>(module_data);

    data->pp_index = model.get_particle_contact_scalars().add("Adhesive Force", "N");
    data->pt_index = model.get_triangle_contact_scalars().add("Adhesive Force", "N");
}

ROCKY_PLUGIN_NON_DIMENSIONALIZE(model, module_data)
{
    auto data = static_cast<ModuleData*>(module_data);

    for (int i = 0; i < model.get_number_of_material_interactions(); ++i)
    {
        data->scale_point_A[i] /= model.get_length_factor();
        data->mod_adhesive_distance[i] /= model.get_length_factor();
    }

    model.get_particle_contact_scalars().set_dimension(data->pp_index, model.get_force_factor());
    model.get_triangle_contact_scalars().set_dimension(data->pt_index, model.get_force_factor());
}

ROCKY_PLUGIN_TEAR_DOWN(model, module_data)
{
    ModuleData* data = static_cast<ModuleData*>(module_data);
    delete[] data->scale_point_A;
    delete[] data->mod_adhesive_distance;
    delete[] data->initial_stiffness_coefficient;
    delete[] data->final_stiffness_coefficient;
    delete data;
}

ROCKY_PLUGIN_INITIALIZE_CUDA(model, host_data, device_id, _device_data)
{
    auto h_data = static_cast<ModuleData*>(host_data);
    auto d_data = *h_data;

    double* d_scale_point_A = nullptr;
    double* d_mod_adhesive_distance = nullptr;
    double* d_initial_stiffness_coefficient = nullptr;
    double* d_final_stiffness_coefficient = nullptr;
    
    int size = model.get_number_of_material_interactions();
    
    CUDA_MALLOC_TYPE(d_scale_point_A, size, double);
    CUDA_MALLOC_TYPE(d_mod_adhesive_distance, size, double);
    CUDA_MALLOC_TYPE(d_initial_stiffness_coefficient, size, double);
    CUDA_MALLOC_TYPE(d_final_stiffness_coefficient, size, double);
    
    CUDA_COPY_H2D(d_scale_point_A, h_data->scale_point_A, size);
    CUDA_COPY_H2D(d_mod_adhesive_distance, h_data->mod_adhesive_distance, size);
    CUDA_COPY_H2D(d_initial_stiffness_coefficient, h_data->initial_stiffness_coefficient, size);
    CUDA_COPY_H2D(d_final_stiffness_coefficient, h_data->final_stiffness_coefficient, size);

    d_data.scale_point_A = d_scale_point_A;
    d_data.mod_adhesive_distance = d_mod_adhesive_distance;
    d_data.initial_stiffness_coefficient = d_initial_stiffness_coefficient;
    d_data.final_stiffness_coefficient = d_final_stiffness_coefficient;

    ModuleData* device_data = nullptr;
    CUDA_MALLOC_TYPE(device_data, 1, ModuleData);
    CUDA_COPY_H2D(device_data, &d_data, 1);
    _device_data = static_cast<void*>(device_data);
}


ROCKY_PLUGIN_TEAR_DOWN_CUDA(model, device_id, device_data)
{
    auto d_data = static_cast<ModuleData*>(device_data);
    ModuleData data_ptrs;
    CUDA_COPY_D2H(&data_ptrs, d_data, 1);
    
    CUDA_FREE(data_ptrs.scale_point_A);
    CUDA_FREE(data_ptrs.mod_adhesive_distance);
    CUDA_FREE(data_ptrs.initial_stiffness_coefficient);
    CUDA_FREE(data_ptrs.final_stiffness_coefficient);

    CUDA_FREE(d_data);
}

ROCKY_PLUGIN_COMPUTE_ADHESIVE_DISTANCES(adhesive_distance_data, _data)
{
    auto data = static_cast<ModuleData*>(_data);

    int n_groups = adhesive_distance_data.get_number_particle_groups();
    for (int i = 0; i < n_groups; i++)
    {
        int m_index_i = adhesive_distance_data.get_particle_material_index(i);
        for (int j = i; j < n_groups; j++)
        {
            int m_index_j = adhesive_distance_data.get_particle_material_index(j);
            adhesive_distance_data.set_adhesive_distance(m_index_i, m_index_j, 0.0);
        }
        for (int bm = 0; bm < adhesive_distance_data.get_number_geometry_materials(); ++bm)
        {
            int m_index_bm = adhesive_distance_data.get_geometry_material_index(bm);
            adhesive_distance_data.set_adhesive_distance(m_index_i, m_index_bm, 0.0);
        }
    }
}

inline ROCKY_FUNCTIONS void set_contact_scalar_value(const IRockyContact& contact, int pp_scalar_index, int pt_scalar_index, double value)
{
    contact.is_particle_particle_contact()
        ? contact.get_particle_contact_scalars().set_scalar(pp_scalar_index, value)
        : contact.get_triangle_contact_scalars().set_scalar(pt_scalar_index, value);
}

inline ROCKY_FUNCTIONS double get_contact_scalar_value(const IRockyContact& contact, int pp_scalar_index, int pt_scalar_index)
{
    if (contact.is_particle_particle_contact())
    {
        auto pp_scalars = contact.get_particle_contact_scalars();
        return -pp_scalars.get_scalar(pp_scalar_index);
    }
    else
    {
        auto pt_scalars = contact.get_triangle_contact_scalars();
        return -pt_scalars.get_scalar(pt_scalar_index);
    }
}

ROCKY_PLUGIN_COMPUTE_CONTACT_ADHESIVE_FORCES(contact, output_data, _data)
{
    auto data = static_cast<ModuleData*>(_data);

    const auto m_i = contact.get_material_interaction();

    int interaction_index = contact.get_material_interaction_index();

    const double loading_stiffness = contact.get_equivalent_stiffness() * m_i.get_stiffness_multiplier();

    const double overlap = contact.get_overlap();

    double z_position = contact.get_contact_position().z;

    double adhesive_force = 0.0;

    if (-overlap < (data->mod_adhesive_distance[interaction_index]))
    {
        if ((data->scale_point_A[interaction_index]) > z_position) {
            adhesive_force = (data->initial_stiffness_coefficient[interaction_index]
                * loading_stiffness * (data->mod_adhesive_distance[interaction_index] + fabs(overlap)));
        }
        else
        {
            adhesive_force = (data->final_stiffness_coefficient[interaction_index]
                * loading_stiffness * (data->mod_adhesive_distance[interaction_index] + fabs(overlap)));
        }
    }

    set_contact_scalar_value(contact, data->pp_index, data->pt_index, adhesive_force);    

    output_data.set_normal_force(get_contact_scalar_value(contact, data->pp_index, data->pt_index));
}
ROCKY_PLUGIN_COMPUTE_CONTACT_ADHESIVE_FORCES_END()

ROCKY_PLUGIN_END