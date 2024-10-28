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

 * ``` DispConfig[]```

Display the system's current configuration in a unit sphere


 * ``` DispM[S1_,S2_]``` and ``` DispM[theta1_,theta2_,phi1,phi2]```

Display the the two unitary magnetic moments with position specified by two vectors ```S1``` and ```S2``` or four angle variables ```theta1,theta2,phi1,phi2``` with ```theta``` for polar angle and ```phi``` for azmuthal angle.


 * ``` AFMEnergy[S1_,S2_]```

Returns the magentic enenrgy (arbitary unit, see convention part) when two magnetic moments are in the positions specified by the vectors ```S1``` and ```S2```.


* ```FindEnergyMinima[theta10_, theta20_, Phi10_, Phi20_, switch_:"on"]```

Find one energy minimum with starting position S1={Sin[theta10]]*Cos[Phi10], Sin[Theta10]*Sin[\Phi10], Cos[Theta10]}; S2={Sin[Theta20]*Cos[Phi2], Sin[Theta20]*Sin[Phi2], Cos[theta20]}. If switch=="off", a five-component vector will be return, containing the ground state energy, and four angles for the two magnetic moments at the energy minimum point. If switch=="on" (default values), the function will return a table for better visualization.

* ```FindGS[switch_="on"]```

Find the lowest energy minimum state for the system's current setup.  When switch is turned on (default value), it will return a Graphics3D object, showing the ground state configuration.
When switch is turned off (for the input of other function), it will only returns a four-component vectors contains the angles of S1 and S2. This function will find the ground state with initial direction running over all the directions of easy axis and hard-axis planes (including Zeenman field). It's the user's responsibility to check whether this is the true ground state by examing where the energy has reached the lowest energy point and the torque are vanishing (will be shown when switch is turned on).


* ```EvloveToEq[G_, dt_:0.001, tmax_:5000, m1i_, m2i_] ```

Find the equilibirum position of the two sublattice magnetization by evolving the current system according to the LLG equation. To have a fast convengence and relable result, a large Gilber damping ```G``` and small time step ```dt``` (default: 0.001) should be used. The magnetization will be evolved with ```tmax``` times (default: 5000) with initial position given by two three-component vectors ```m1i``` and ```m2i```. It's the user's responsibility to check whether the outcome is consistent with the results from ```FindEnergyMinima``` or ```FindGS``` function.
