# dem-msw-particles

This repository supports modeling and calibration of municipal solid waste (MSW) particles for Discrete Element Method (DEM) simulations, with focus on particles properties and model parameters.

Calibration datasets for varying particle and model properties, together with custom user-defined modules for DEM simulations based on Ansys Rocky 2024 R1.

---

## Repository Content

- Custom Ansys Rocky DEM modules
  - Spatially varying adhesion properties
  - Transient particle mass and volume scaling
- Calibration data (CSV file)
  - Output of a large-scale DEM calibration campaign
  - Parameter mapping results for MSW particle 

---

## Mod Adhesion Off

This module modifies the stiffness fraction of the linear adhesive force model depending on the spatial position of the particle.

A threshold along the Z-coordinate is defined, above or below which the adhesive interaction properties are altered.

### Main features
- Spatially dependent modification of adhesive stiffness
- Optional adjustment of the adhesive distance
- User-defined Z-coordinate limit
- Compatible with Ansys Rocky 2024 R1 linear adhesive force model
  
---

## Mod Transient Size Scale Ext

This module enables modification of particle mass and volume based on the particle’s position along the Z-coordinate.

The spatial domain is divided into five segments, where:
- The first and last segments keep the particle mass and volume constant regarding the first and last scale factors.
- The three intermediate segments apply linear scaling functions based on user-defined scale factors

The particle density is assumed to remain constant throughout the simulation.

### Main features
- Three independent scaling factors
- Five spatial segments along the Z coordinate
- Linear volume and mass variation in intermediate regions
- Initial volume index and scaling factor stored per particle as reference
- Automatic mass and volume adaptation during simulation

Mass and volume changes are unidirectional:  
particles moving backward into previous segments retain their already modified properties, preventing unphysical growth effects, as the currect state of the module.

---

## Mapping Stage Results

This repository includes CSV files containing the results of a calibration mapping stage consisting of 620 DEM simulations.

The calibration targets municipal solid waste (MSW) particles and is based on a 35 MWth Waste-to-Energy power plan as reference geometry and operating conditions.

The data serves as reference for further calibration and modeling approaches. 

### Calibration parameters
The following particle and interaction parameters were varied:

1. Stiffness coefficient  
2. Rolling resistance coefficient  
3. Friction coefficient  
4. Particle specific density  

### Output metrics
The simulation outputs used for comparison and calibration include:

1. Average particle mass flow from the ram feeder section  
2. Average maximum force per cycle from the rams
3. Average minimum force per cycle from the rams 
4. Total mechanical work per cycle from the rams 

The simulation setup consider ten ram cycles, and due to initialization issues, the last seven cycles are considered for analysis.
   
Legend description, dimensions in square brackets
- "ID" Simulation ID
- "DensT" Specific density
- "FritC" Friction coefficient
- "StifF" Stiffness fraction
- "RollR" Rolling resistance coefficient
- "Total_Acum_Mass_Ini [kg]" Total accumulated mass at the end of the ram feeder section
- "Total_Acum_Mass_Out [kg]" Total accumulated mass at the end of the grate section
- "AVG_W_IN [kg/s]" Average mass flow per cycle at the end of the ram feeder section, calculated from the last seven cycles
- "SD_W_IN [kg/s]" Standard deviation of the mass flow per cycle at the end of the ram feeder section, calculated from the last seven cycles
- "AVG_TOT_IN [kg/s]" Average mass flow per cycle at the end of the ram feeder section, calculated from the ten cycles
- "AVG_W_OUT [kg/s]" Average mass flow per cycle at the end of the grate section, calculated from the last seven cycles
- "SD_W_OUT [kg/s]" Standard deviation of the mass flow per cycle at the end of the grate section, calculated from the last seven cycles
- "AVG_TOT_OUT [kg/s]" Average mass flow per cycle at the end of the grate section, calculated from the ten cycles
- "Slider_Left_MAX_AVG [kN]" Average maximum force per cycle at the left ram, of the last 7 cycles
- "Slider_Left_MAX_SD [kN]" Standard deviation of the maximum force per cycle at the left ram, of the last 7 cycles
- "Slider_Left_MIN_AVG [kN]" Average minimum force per cycle at the left ram, of the last 7 cycles
- "Slider_Left_MIN_SD [kN]" Standard deviation of the minimum force per cycle at the left ram, of the last 7 cycles
- "Slider_Right_MAX_AVG [kN]" Average maximum force per cycle at the right ram, of the last 7 cycles
- "Slider_Right_MAX_SD [kN]" Standard deviation of the maximum force per cycle at the right ram, of the last 7 cycles
- "Slider_Right_MIN_AVG [kN]" Average minimum force per cycle at the right ram, of the last 7 cycles
- "Slider_Right_MIN_SD [kN]" Standard deviation of the minimum force per cycle at the right ram, of the last 7 cycles
- "Slider_Total_MAX_AVG [kN]" Average maximum total force per cycle, of the last 7 cycles
- "Slider_Total_MAX_SD [kN]" Standard deviation of the maximum total force per cycle, of the last 7 cycles
- "Slider_Total_MIN_AVG [kN]" Average minimum total force per cycle, of the last 7 cycles
- "Slider_Total_MIN_SD [kN]" Standard deviation of the minimum total force per cycle, of the last 7 cycles
- "WoT_AVG [kJ]" Average total work per cycle, considering the total force, of the last 7 cycles
- "WoT_SD [kJ]" Standard deviation of the total work per cycle, considering the total force, of the last 7 cycles

---

## License

- Code (modules, scripts, build files): MIT License
- Data (CSV calibration dataset): Creative Commons Attribution 4.0 (CC-BY 4.0)

See the `LICENSE` file for full details.

---

## Citation

If you use this repository in academic or technical work, please cite the corresponding Zenodo record (DOI provided upon release).

---

## Author

M.Sc. Matías Alonso Fierro Rivas  
Technical University of Munich (TUM)  
https://www.epe.ed.tum.de/es/mitarbeiterinnen/aktuelle-mitarbeiterinnen/wiss-mitarbeiterinnen/fierro/


















