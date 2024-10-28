# AFMVisualize
A Mathematica Paclet that allows for visualzation of two-sublattice antiferromagnetic dynamics with arbitary input, including Easy-axis anisotropy fields, hard-axis anisotropy fields, Zeeman fields, spin torques (time-dependent or indepedent Field-like torques and Antidamping-like torques).
The usual workflow is as
* Set up the system's magnetic params
* Find equilibirum position of the magnetization (ground state)
* Solve the eigenmodes (resonance mode)
* Visualize the antiferromagnetic dynamcis
<img src="./Demo/demo.png" alt="Alt Text" width="370" height="600">

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


## Functions

The files ```Example.nb``` contains serveral basic instance regarding how to use this package.

See the convention part at the end of this page for how the parameters and their units are defined.

Available functions are:

* ```ResetAll[]```
  
Clear the inputs and reset all the parameters to their default values

* ```SetExchange[J_]```

 Set the AFM exchange strength (arbitary unit, positive) $B_E=J$. 

 * ``` AddEasyAxis[Amp_, Dir_]```

 Add one Easy axis to the system with magnitude $B_A$=```Amp```(>0) in the direction given by ```Dir```. The function will automatically normalize the ```Dir``` vector.

 * ``` AddHardAxis[Amp_, Dir_]```

Add one Hard axis to the system with magnitude $B_H$=```Amp```(<0) in the direction given by ```Dir```. The function will automatically normalize the ```Dir``` vector.

 * ``` AddBFieldDC[Amp_, Dir_]```

Add one DC Zeeman field to the system with magnitude $B_0$=```Amp``` in the direction given by ```Dir```. The function will automatically normalize the ```Dir``` vector. For AC Zeeman field, it's treated as the driving force (see the Spin torque part).

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
When switch is turned off (for the input of other function), it will only returns a four-component vectors contains the angles of S1 and S2. This function will find the ground state with initial direction running over all the directions of easy axis and hard-axis planes (including Zeenman field). **It's the user's responsibility to check whether this is the true ground state by examing where the energy has reached the lowest energy point and whether the torque are vanishing (will be shown when switch is turned on).**


* ```EvloveToEq[G_, dt_:0.001, tmax_:5000, m1i_, m2i_] ```

Find the equilibirum position of the two sublattice magnetization by evolving the current system according to the LLG equation. The partial differential equations are solved with simplified mid-point (implicit) method. **It's the user's responsibility to check the stability and check whether the outcome is consistent with the results from ```FindEnergyMinima``` or ```FindGS``` function.** To have a fast convengence and relable result, a large Gilber damping ```G``` and small time step ```dt``` (default: 0.001) should be used. The magnetization will be evolved with ```tmax``` times (default: 5000) with initial position given by two three-component vectors ```m1i``` and ```m2i```. 

* ```PlotEigen[]```

 Plot the eigenmode (resonance mode) for the current system's setup. This function will first find the ground state of the system and then linearized the LLG equation without damping and driving fields around each subllattice magnetization's equilibrium position. It will return a ```manuplate``` plot that allows the user to finely tune the demonstration and visualize the magnetization dynamics.


 * ```AFMDynmaics[G_, dt_ ,tmax_, FL_, DL_, m1i, m2i]```

Visualize the AFM dynamics for the current system's setup with driving field. The input are: Gilbert damping ```G```, time step ```dt```, maximum interation times ```tmax```, Field-like torques ```FL```, Antidamping-like torques ```DL```, initial position of the two sublattice magnetic moment ```m1i``` and ```m2i```. The input spin torques ```FL``` and ```DL``` should be a function that returns the spin polarization (three component vectors) at each time. It can be either a constant function or a time-dependent function defined by the user such as ```FL[t_]:={Cos[t],Sin[t],0}```.

# Conventions

The angular gyromagnetic ratio is set to be $\gamma=0.176085963023$ THz*rad/T

This means it's better for the users to intepretate their the effective fields to be in the Telsa unit [T] such that the times scale is ps (picosecond).

For example, when the time step ```dt=0.01``` and the system has interation times ```tmax=1000```, with all fields in Telsa unit, this means that the system has evolved 0.01*1000 = 10 ps.

The energy functional for the AFM system we adopt in this package is

$E[m_1,m_2]= J m_1\cdot m_2 -K_a (m_1\cdot \hat{n}_a)^2 -K_a (m_2\cdot \hat{n}_a)^2 -K_h (m_1\cdot \hat{n}_h)^2 -K_h (m_2\cdot \hat{n}_h)^2 - H_0 (m_1+m_2)$

Note that we have adopt the convention that the magnetic moment is a dimensionaless and unitary vectors so all the parameters in the above equation has energy unit.

To simulate a system with magnetic moment $\hbar \gamma S$ with $S the quantum spin number$, one can obtain the effective field according $H^{eff}_i=-\partial E/\gamma\hbar S\partial m_i$.

Therefore, we have the the following expressions for the effective fields of exchange interaction, anisotropy field and Zeeman field:

$B^{ex}_1 = -B_E m_2\ \ \ B^{ex}_2 = -B_E m_1\ \ \ B_E=J/\hbar \gamma S >0$

$B^{easy}_i = B_A*(m_i\cdot \hat{n}_a) \hat{n}_a,\ \ \ B_A=2K_a/\hbar\gamma S >0$

$B^{hard}_i = B_H*(m_i\cdot \hat{n}_h) \hat{n}_h,\ \ \ B_H=2K_h/\hbar\gamma S <0$

$B_0 = H_0/\hbar\gamma S$
