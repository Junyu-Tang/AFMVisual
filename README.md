# AFMVisualize
A Mathematica Paclet that allows for visualzation of two-sublattice antiferromagnetic dynamics with arbitary input, including Easy-axis anisotropy fields, hard-axis anisotropy fields, Zeeman fields, spin torques (time-dependent or indepedent Field-like torques and Antidamping-like torques).
The usual Workflow is as
* Set up the system's magnetic params
* Find equilibirum position of the magnetization (ground state)
* Solve the eigenmodes (resonance mode)
* Visualize the antiferromagnetic dynamcis

## Installation

Download and put the AFMVisualize.wl file in the following path
```
Mathematica\Contents\AddOns\ExtracPackages
```
or somewhere your Mathematica could find ($Path).

To load the package:
```
Needs["AFMVisualize`"]
```
The following command will reload the package (overwite the variables) every time being called

```Get["AFMVisualize`"] ```

which is equivalent with
```
<<"AFMVisualize`"
```
After the package is sucessfully loaded, type ```?AFMVisualize`* ``` to see all variables and available functions.


## Tutorial

The files ```Example.nb``` contains serveral basic instance regarding how to use this package.

See the convention part at the end of this page for how the parameters and their units are defined.

Available functions are:

* ```ResetAll[]```
  
Clear the inputs and reset all the parameters to their default values

* ```SetExchange[J_]```

 Set the AFM exchange strength (arbitary unit, positive) BE=J. 

 * ``` AddEasyAxis[Amp_, Dir_]```

 Add one Easy axis to the system with magnitude BA=```Amp```(>0) in the direction given by ```Dir```. The function will automatically normalize the ```Dir``` vector.

 * ``` AddHardAxis[Amp_, Dir_]```

Add one Hard axis to the system with magnitude BH=```Amp```(<0) in the direction given by ```Dir```. The function will automatically normalize the ```Dir``` vector.

 * ``` AddBFieldDC[Amp_, Dir_]```

Add one DC Zeeman field to the system with magnitude BH=```Amp``` in the direction given by ```Dir```. The function will automatically normalize the ```Dir``` vector. For AC Zeeman field, it's treated as the driving force (see the Spin torque part).

 * ``` RemoveEasy[i_]```

Remove ```i```-th Easy axis.
  
 * ``` RemoveHard[i_]```

Remove ```i```-th Hard axis.


 * ``` RemoveBFieldDC[i_]```

Remove ```i```-th DC Zeeman field.
