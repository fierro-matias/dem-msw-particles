import sys
from pathlib import Path

from rocky20.addins.addin_models import data_model, container_model
from rocky20.addins.addin_specs import RockyAddinSpecs
from rocky20.addins.addin_types import Quantity, Boolean, String, List, PointCloudName, ParticleName, MassIncrement, VolumeIncrement, ScalarProperties
from yapsy.IPlugin import IPlugin

NAME = "Mod Transient Size Scale Ext"

@data_model(icon=None, caption=NAME)
class ModTransientScaleExtModel:
    pass

@container_model()
class ModTransientScaleExtParticleInput:
    mass_increment = MassIncrement
    volume_increment = VolumeIncrement

@container_model()
class ModTransientScaleExtParticleGroupProperties:    
    scale_point_A = Quantity(value=2.400, unit='m', caption='Point A')
    scale_point_B = Quantity(value=4.023, unit='m', caption='Point B')
    scale_point_C = Quantity(value=4.688, unit='m', caption='Point C')
    scale_point_D = Quantity(value=6.179, unit='m', caption='Point D')
    scale_size_factor_B = Quantity(value=0.88344, unit='-', caption='Size Factor at B')
    scale_size_factor_C = Quantity(value=0.71276, unit='-', caption='Size Factor at C')
    scale_size_factor_D = Quantity(value=0.60966, unit='-', caption='Size Factor at D')


class ModTransientScaleExtSpecs(RockyAddinSpecs):
    name = NAME
    model = ModTransientScaleExtModel
    particle_input_properties = ModTransientScaleExtParticleInput
    particle_group_properties = ModTransientScaleExtParticleGroupProperties
    
    @classmethod
    def CreateAddin(cls):
        return cls.CreateDynamicAddin(Path(__file__).parent, 'mod_transient_size_scale_ext')

class ModTransientScaleExtPlugin(IPlugin):
    def get_addin_specs(self):
        return ModTransientScaleExtSpecs