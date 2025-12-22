# dem-msw-particles

Calibration datasets for spatially varying particle and model properties, together with custom user-defined modules for DEM simulations based on Ansys Rocky 2024 R1.

This repository supports advanced modeling and calibration of municipal solid waste (MSW) particles in industrial DEM applications, with a focus on spatially dependent material behavior and parameter mapping.

---

## Repository Content

- Custom Ansys Rocky DEM modules
  - Spatially varying adhesion properties
  - Transient particle mass and volume scaling
- Calibration datasets (CSV files)
  - Output of a large-scale DEM calibration campaign
  - Parameter mapping results for MSW particle modeling

---

## Mod Adhesion Off

This module modifies the stiffness fraction of the linear adhesive force model depending on the spatial position of the particle.

A threshold along the Z-coordinate is defined, above or below which the adhesive interaction properties are altered.

### Main features
- Spatially dependent modification of adhesive stiffness
- Optional adjustment of the adhesive distance
- User-defined Z-coordinate limit
- Compatible with Ansys Rocky 2024 R1 linear adhesive force model

This module enables localized activation or deactivation of adhesive behavior, which is particularly useful for modeling heterogeneous process zones.

---

## Mod Transient Size Scale Ext

This module enables transient modification of particle mass and volume based on the particle’s position along the Z-coordinate.

The spatial domain is divided into five segments, where:
- The first and last segments keep the particle mass and volume constant regarding the first and last scale factors.
- The three intermediate segments apply linear scaling functions based on user-defined scale factors

The particle density is assumed to remain constant throughout the simulation.

### Main features
- Three independent scaling factors
- Five spatial Z-segments
- Linear volume and mass variation in intermediate regions
- Initial volume index and scaling factor stored per particle as reference
- Automatic mass and volume adaptation during simulation

Mass and volume changes are unidirectional:  
particles moving backward into previous segments retain their already modified properties, preventing unphysical growth effects.

---

## Mapping Stage Results

This repository includes CSV files containing the results of a calibration mapping stage consisting of 620 DEM simulations.

The calibration targets municipal solid waste (MSW) particles and is based on a 35 MWth Waste-to-Energy power plan as reference geometry and operating conditions.

### Calibration parameters
The following particle and interaction parameters were varied:

1. Stiffness coefficient  
2. Rolling resistance coefficient  
3. Friction coefficient  
4. Particle specific density  

### Output metrics
The simulation outputs used for comparison and calibration include:

1. Average particle mass flow from the ram feeder section  
2. Average maximum force per cycle  
3. Average minimum force per cycle  
4. Total mechanical work per cycle  

These datasets can be used for:
- Reproducing the calibration procedure
- Sensitivity and uncertainty analysis
- Parameter optimization
- Reduced-order or surrogate modeling

  Legend description
- "ID"
- "FritC"
- "StifF"
- "RollR"
- "Total Acum Mass Ini [kg]"
- "Total Acum Mass Out [kg]"
- "AVG_W_IN [kg/s]"
- "SD_W_IN [kg/s]"
- "AVG_TOT_IN [kg/s]"
- "AVG_W_OUT [kg/s]
- "SD_W_OUT [kg/s]
- "AVG_TOT_OUT [kg/s]
- "Slider_Left_MAX_AVG [kN]"
- "Slider_Left_MAX_SD [kN]"
- "Slider_Left_MIN_AVG [kN]"
- "Slider_Left_MIN_SD [kN]"
- "Slider_Right_MAX_AVG [kN]"
- "Slider_Right_MAX_SD [kN]"
- "Slider_Right_MIN_AVG [kN]"
- "Slider_Right_MIN_SD [kN]"
- "Slider_Total_MAX_AVG [kN]"
- "Slider_Total_MAX_SD [kN]"
- "Slider_Total_MIN_AVG [kN]"
- "Slider_Total_MIN_SD [kN]"
- "WoT_AVG [kJ]"
- "WoT_SD [kJ]"

---

## Software Requirements

- **Ansys Rocky 2024 R1**
- CUDA-compatible GPU (for CUDA modules)
- CMake and a compatible C++ compiler
- Python 3.x (if using auxiliary scripts)

A valid Ansys Rocky license is required to compile and run the modules.  
No proprietary Ansys binaries are included in this repository.

---

## License

- Code (modules, scripts, build files): MIT License
- Data (CSV calibration datasets): Creative Commons Attribution 4.0 (CC-BY 4.0)

See the `LICENSE` file for full details.

---

## Citation

If you use this repository in academic or technical work, please cite the corresponding Zenodo record (DOI provided upon release).

---

## Author

M.Sc. Matías Alonso Fierro Rivas  
Technical University of Munich (TUM)  
https://www.epe.ed.tum.de/es/mitarbeiterinnen/aktuelle-mitarbeiterinnen/wiss-mitarbeiterinnen/fierro/


















