import sys
from pathlib import Path
from rocky20.addins.addin_models import data_model, container_model
from rocky20.addins.addin_specs import RockyAddinSpecs
from rocky20.addins.addin_types import Quantity, Boolean, String, List, PointCloudName, ParticleName, ScalarProperties
from yapsy.IPlugin import IPlugin

NAME = 'Mod Adhesion Off'

@data_model(icon=None, caption=NAME)
class ModAdhesionOffModel:
    pass

@container_model()
class ModAdhesionOffMaterialInteraction:
    scale_point_A = Quantity(value= 3.731, unit='m', caption='Point A in Z axis')    
    mod_adhesive_distance = Quantity(value= 0.0001, unit='m', caption='Adhesive Distance')    
    initial_stiffness_coefficient = Quantity(value= 0.0, unit='-', caption='Initial Stiffness Fraction')    
    final_stiffness_coefficient = Quantity(value= 0.0, unit='-', caption='Final Stiffness Fraction')    

class ModAdhesionOffSpecs(RockyAddinSpecs):
    name = NAME
    model = ModAdhesionOffModel
    adhesion_model = ModAdhesionOffModel
    material_interaction_properties = ModAdhesionOffMaterialInteraction
    @classmethod
    def CreateAddin(cls):
        return cls.CreateDynamicAddin(Path(__file__).parent, 'mod_adhesion_off')

class ModAdhesionOffPlugin(IPlugin):
    def get_addin_specs(self):
        return ModAdhesionOffSpecs