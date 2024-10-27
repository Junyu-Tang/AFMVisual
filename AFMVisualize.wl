(* ::Package:: *)

BeginPackage["AFMVisualize`"]
	(* 
	   Conventions:
	   dm/dt =-\[Gamma] m\[Cross]H + \[Alpha] m x dm/dt
	   H = J*M1*M2 - Ka(M1.na)^2 - Ka(M2.na)^2 - Kh(M1.nh)^2 - Kh(M2.nh)^2 - H0*(M1+M2)
	   M1 and M2 are dimensionaless and unitary vectors. True magnetic moment is \[HBar]\[Gamma]S with S the quantum spin number 
	   All params (J, Ka, Kh, H0) are in energy unit
	   Exchange fields:    Bex1=-BE*M2, Bex2=-BE*M1, BE=J/\[HBar]\[Gamma]S > 0
	   Easy axis anisotropy fields:  B_easy=BA*(M.na)na, BA=2Ka/\[HBar]\[Gamma]S>0, with na (unitary vector) pointing to the direction of EasyAxis
	   Hard axis anisotropy fields:  B_hard=BH*(M.nh)nh, BH=2Kh/\[HBar]\[Gamma]S<0, with nh (unitary vector) pointing to the direction of HardAxis
	   Zeeman fields:                B0 = H0/\[HBar]\[Gamma]S
	 *)
	
	(* Public variables and functions *)
	BE::usage = "Positive exchange field";
	EasyAxis::usage = "Magnitude & direction of Easy axis";
	HardAxis::usage = "Magnitude & direction of hard axis";
	SetExchange::usage = "Set exchange strength";
	AddEasyAxis::usage = "Add one easy axis";
	AddHardAxis::usage = "Add one hard axis";
	AddBFieldDC::usage = "Add one DC magnetic field (flux)";
	RemoveEasy::usage  = "Remove one easy axis";
	RemoveHard::usage  = "Remove one easy axis";
	ResetAll::usage    = "Reset every magnetic params";
	DispConfg::usage   = "Display the field configurations";
	DispM::usage       = "Display the magnetic moments";
	\[Gamma]::usage           = "Angular gyromagnetic ratio: THZ*rad/Telsa";
	PlotEigen::usage   = "Plot the eigenmodes";
	EvolveToEq::usage  = "Find the equilibirum position";
	AFMDynamics::usage = "Find M1 and M2 dynamics with input fields";
	FindEnergyMinima::usage = "Find all possible energy minima";
	FindGS::usage = "Find lowest energy minima";
	AFMEnergy::usage = "Calcuate the AFM energy";
	Meq::usage="test";
	
	BE = 1;       (* Exchange strength BE=J/\[HBar]\[Gamma]S. Default value: 1 *)
	EasyAxis = {};(* Stores the magnitudes (BA=2Ka/\[HBar]\[Gamma]S>0) and normalized directional vectors of easy axis *)
	HardAxis = {};(* Stores the magnitudes (BH=2Kh/\[HBar]\[Gamma]S<0) and normalized difectional vectors of hard axis *)
	BFieldDC = {};(* Stores DC Zeeman fields B0 = H0/\[HBar]\[Gamma]S *)
	\[Gamma] = 0.176085963023;(* Angular gyromagnetic ratio with unit THZ*rad/Tels such that time is in picosecond scale*)
	AFMVersion = "1.0.0";
	


Begin["`Private`"]
	ResetAll[] := (EasyAxis = {}; HardAxis = {}; BFieldDC = {}; BE=1;)
	SetExchange[J_] := If[J>0 && FreeQ[J, _complex], (BE=J;), Print["Fail! Exchange strength ust be real and positive for AFM!"]];
	AddEasyAxis[Amp_, D_] := If[Amp>0 && FreeQ[D, _complex], (AppendTo[EasyAxis, {Amp, Normalize[D]}];), Print["Fail! For easy axis, magnitude must be positive and directional vector must be real!"]];
	AddHardAxis[Amp_, D_] := If[Amp<0 && FreeQ[D, _complex], (AppendTo[HardAxis, {Amp, Normalize[D]}];), Print["Fail! For hard axis, magnitude must be negative and directional vector must be real!"]];
	AddBFieldDC[Amp_, D_] := If[Amp!=0 && FreeQ[D, _complex], (AppendTo[BFieldDC, {Amp, Normalize[D]}];), Print["Fail! Magnitude cannot be zero and the directional vector must be real!"]];
	RemoveEasy[i_] := (EasyAxis = Delete[EasyAxis, i];)
	RemoveHard[i_] := (HardAxis = Delete[HardAxis, i];)
	
	(* Display the system's params *)
	DispParams[] := Module[{pair,vars,values},
					vars={"Fields", "J", "B0", "BA", "BH"};
					values={" Values", BE, BFieldDC, EasyAxis, HardAxis};
					pair=Transpose[{vars,values}];
					Grid[pair,Frame->All,Alignment->Left,ItemStyle->{Automatic},Background->{{Lighter[Blue,0.7]},Lighter[Yellow,0.9]},Dividers->{True,{True,True}}]];
					
	(* Display the field configurations in a unit sphere *)
	DispConfg[switch_:"on"] := Module[{BFields, AFields, HFields, fig},
					If[Length[BFieldDC]>0, BFields=Table[{Green,  Arrow[{{0,0,0},0.7*BFieldDC[[i,2]]}],Black,Text[Style["B" <>ToString[i]<>"="<>ToString[Norm[BFieldDC[[i,1]]]],12,Italic],0.7*BFieldDC[[i,2]],{1.2,1.2}]},{i,Length[BFieldDC]}], BFields={}];
					If[Length[EasyAxis]>0, AFields=Table[{Magenta,Arrow[{{0,0,0},0.5*EasyAxis[[i,2]]}],Black,Text[Style["Ha"<>ToString[i]<>"="<>ToString[Norm[EasyAxis[[i,1]]]],12,Italic],0.5*EasyAxis[[i,2]],{1.2,1.2}]},{i,Length[EasyAxis]}], AFields={}];
					If[Length[HardAxis]>0, HFields=Table[{Orange, Arrow[{{0,0,0},0.5*HardAxis[[i,2]]}],Black,Text[Style["Hh"<>ToString[i]<>"="<>ToString[Norm[HardAxis[[i,1]]]],12,Italic],0.5*HardAxis[[i,2]],{1.2,1.2}]},{i,Length[HardAxis]}], HFields={}];
					fig=Graphics3D[{{Black,Arrow[{{0,0,0},{1.4,0,0}}],Text["X",{1.5,0,0}]},{Black,Arrow[{{0,0,0},{0,1.4,0}}],Text["Y",{0,1.5,0}]},{Black,Arrow[{{0,0,0},{0,0,1.4}}],Text["Z",{0,0,1.5}]},
					{Opacity[0.1],Gray,Sphere[{0,0,0},1]}, BFields, AFields, HFields},ImageSize->Medium,Boxed->False,Axes->False,PlotRange->All];
					If[switch=="on", Row[{fig,DispParams[]},Spacer[0]], fig]];
					
	(* Display the Magnetic configurations *)
	DispM[S1_, S2_] := Graphics3D[{{Blue,Arrow[{{0,0,0},Normalize[S1]}],Text["M1",1.1*Normalize[S1]]},{Red,Arrow[{{0,0,0},Normalize[S2]}],Text["M2",1.1*Normalize[S2]]}},Boxed->False,Axes->False,PlotRange->All];
	DispM[\[Theta]1_,\[Theta]2_,\[Phi]1_,\[Phi]2_] := Module[{S1, S2}, S1={Sin[\[Theta]1]*Cos[\[Phi]1], Sin[\[Theta]1]*Sin[\[Phi]1], Cos[\[Theta]1]}; S2={Sin[\[Theta]2]*Cos[\[Phi]2], Sin[\[Theta]2]*Sin[\[Phi]2], Cos[\[Theta]2]};
								Graphics3D[{{Blue,Arrow[{{0,0,0},S1}],Text["M1",1.1*S1]},{Red,Arrow[{{0,0,0},S2}],Text["M2",1.1*S2]}},Boxed->False,Axes->False,PlotRange->All]];
					
	(* Energy functional. Unit: \[HBar]\[Gamma]S*T *)
	AFMEnergy[S1_, S2_] := Module[{Heisenberg,Easy,Hard,Zeeman}, Heisenberg = BE*(S1 . S2);
							If[Length[EasyAxis]>0, Easy=Sum[-EasyAxis[[i,1]]*((S1 . EasyAxis[[i,2]])^2+(S2 . EasyAxis[[i,2]])^2)/2.0,{i,1,Length[EasyAxis]}], Easy=0];
							If[Length[HardAxis]>0, Hard=Sum[-HardAxis[[i,1]]*((S1 . HardAxis[[i,2]])^2+(S2 . HardAxis[[i,2]])^2)/2.0,{i,1,Length[HardAxis]}], Hard=0];
							If[Length[BFieldDC]>0, Zeeman=Sum[-BFieldDC[[i,1]]*(S1+S2) . BFieldDC[[i,2]],{i,1,Length[BFieldDC]}], Zeeman=0];
							Heisenberg+Easy+Hard+Zeeman];
							
	(* Find one local energy minima *)
	FindEnergyMinima[\[Theta]10_, \[Theta]20_, \[Phi]10_, \[Phi]20_,switch_:"on"] := Module[{S1,S2,\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,Sol,vars,values,pair}, S1={Sin[\[Theta]1]*Cos[\[Phi]1], Sin[\[Theta]1]*Sin[\[Phi]1], Cos[\[Theta]1]}; S2={Sin[\[Theta]2]*Cos[\[Phi]2], Sin[\[Theta]2]*Sin[\[Phi]2], Cos[\[Theta]2]};
							Sol=FindMinimum[{AFMEnergy[S1,S2], \[Theta]1>=0 && \[Theta]2>=0 && \[Phi]1>=0 && \[Phi]2>=0 && \[Theta]1<=Pi && \[Theta]2<=Pi && \[Phi]1<=2*Pi && \[Phi]2<=2*Pi},{{\[Theta]1,\[Theta]10},{\[Theta]2,\[Theta]20},{\[Phi]1,\[Phi]10},{\[Phi]2,\[Phi]20}},
							Gradient->{D[AFMEnergy[S1,S2],\[Theta]1],D[AFMEnergy[S1,S2],\[Theta]2],D[AFMEnergy[S1,S2],\[Phi]1],D[AFMEnergy[S1,S2],\[Phi]2]}];
							values={Sol[[1]], \[Theta]1/.Sol[[2]], \[Theta]2/.Sol[[2]], \[Phi]1/.Sol[[2]], \[Phi]2/.Sol[[2]]};
							vars={"E", "\[Theta]1", "\[Theta]2", "\[Phi]1", "\[Phi]2"};
							pair=Transpose[{vars,values}];
							If[switch=="on", Grid[pair,Frame->All,Alignment->Left,ItemStyle->{Automatic},Background->{{Lighter[Blue,0.7]},Lighter[Yellow,0.9]},Dividers->{True,{True,True}}], values]];
							
							
	(* Find ground state with lowest energy *)						
	FindGS[switch_:"on"] := Module[{D1,D2,D3,Dtot,EGS,Ind,Sol,Bgplot, Mplot,Btot,S1,S2,t1,t2,p1,p2,\[Tau]1,\[Tau]2,vars,vals,pair,info},
				(* For all easy axis, start with their directions for finding the minima. For all B0 and hard axis, start with an orthorgonal direction instead. *)
				If[Length[EasyAxis]>0, D1=Table[EasyAxis[[i,2]],{i,1,Length[EasyAxis]}], D1={}];
				If[Length[BFieldDC]>0, D2=Table[Normalize[If[BFieldDC[[i,2]]\[Cross]{1,0,0}!={0,0,0}, BFieldDC[[i,2]]\[Cross]{1,0,0}, BFieldDC[[i,2]]\[Cross]{0,1,0}]],{i,1,Length[BFieldDC]}], D2={}];
				If[Length[HardAxis]>0, D3=Table[Normalize[If[HardAxis[[i,2]]\[Cross]{1,0,0}!={0,0,0}, HardAxis[[i,2]]\[Cross]{1,0,0}, HardAxis[[i,2]]\[Cross]{0,1,0}]],{i,1,Length[HardAxis]}], D3={}];
				If[Length[BFieldDC]>0, Btot=Sum[BFieldDC[[i,1]]*BFieldDC[[i,2]],{i,1,Length[BFieldDC]}], Btot={0,0,0}];
				Dtot = D1~Join~D2~Join~D3; If[Length[Dtot]<1,(Print["At least one input for effective field is required to determine the ground state!"];Abort[])];
				Sol=Table[Module[{\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2},
							\[Theta]1=ArcCos[Dtot[[i,3]]]; If[Abs[Dtot[[i,3]]-1]>=10^(-9), \[Phi]1=ArcTan[Dtot[[i,2]],Dtot[[i,1]]], \[Phi]1=0]; \[Theta]2=Pi-\[Theta]1; \[Phi]2=\[Phi]1+Pi; FindEnergyMinima[\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,"off"]],
					{i,1,Length[Dtot]}];
				EGS=Min[Sol[[All,1]]]; Ind=Position[Sol[[All,1]],EGS]; Bgplot=DispConfg["off"];
				t1=Sol[[Ind[[1,1]],2]];
				t2=Sol[[Ind[[1,1]],3]];
				p1=Sol[[Ind[[1,1]],4]];
				p2=Sol[[Ind[[1,1]],5]];
				Mplot=DispM[t1,t2,p1,p2];
				S1={Sin[t1]*Cos[p1], Sin[t1]*Sin[p1], Cos[t1]};
				S2={Sin[t2]*Cos[p2], Sin[t2]*Sin[p2], Cos[t2]};
				\[Tau]1=-\[Gamma]*S1\[Cross](CalAns[S1]+Btot-BE*S2);
				\[Tau]2=-\[Gamma]*S2\[Cross](CalAns[S2]+Btot-BE*S1);
				vars={"E", "\[Theta]1", "\[Theta]2", "\[Phi]1", "\[Phi]2", "\[Tau]1", "\[Tau]2"};
				vals={EGS, t1, t2, p1, p2, Norm[\[Tau]1], Norm[\[Tau]2]};
				pair=Transpose[{vars,vals}];
				info=Grid[pair,Frame->All,Alignment->Left,ItemStyle->{Automatic},Background->{{Lighter[Blue,0.7]},Lighter[Yellow,0.9]},Dividers->{True,{True,True}}];
				If[switch=="on", Row[{Show[Bgplot,Mplot],info},Spacer[0]], {t1,t2,p1,p2}]
				];
	
	(* Find equilibrium position by evolving M with large damping *)
	EvolveToEq[\[Alpha]G_, \[Delta]t_, tmax_, m1i_, m2i_] := Module[{Btot, mag, BFields, AFields, HFields, Bgplot, Mplot, trace, \[Tau]1, \[Tau]2, vars, vals, pair, info},
						mag={{Normalize[m1i], Normalize[m2i]}};
						If[Length[BFieldDC]>0, Btot=Sum[BFieldDC[[i,1]]*BFieldDC[[i,2]],{i,1,Length[BFieldDC]}], Btot={0,0,0}];
						Do[AppendTo[mag, LLGSolver[mag[[j-1,1]], mag[[j-1,2]], Btot, {0,0,0}, BE, \[Alpha]G, \[Delta]t]], {j,2,tmax}];
						Bgplot = DispConfg["off"];
						Mplot=DispM[mag[[tmax,1]], mag[[tmax,2]]];
						trace=Graphics3D[{{Blue, Line[mag[[1;;tmax,1]]]},{Red, Line[mag[[1;;tmax,2]]]}},Boxed->False,Axes->False,PlotRange->All,ImageSize->Medium];
						\[Tau]1=-\[Gamma]*mag[[tmax,1]]\[Cross](CalAns[mag[[tmax,1]]]+Btot-BE*mag[[tmax,2]]);
						\[Tau]2=-\[Gamma]*mag[[tmax,2]]\[Cross](CalAns[mag[[tmax,2]]]+Btot-BE*mag[[tmax,1]]);
						vars={"\[Theta]1", "\[Theta]2", "\[Phi]1", "\[Phi]2", "|\[Tau]1|", "|\[Tau]2|"};
						vals={ArcCos[mag[[tmax,1,3]]], ArcCos[mag[[tmax,2,3]]],
							If[Abs[mag[[tmax,1,3]]-1]>=10^(-9), ArcTan[mag[[tmax,1,2]],mag[[tmax,1,1]]], 0],
							If[Abs[mag[[tmax,2,3]]-1]>=10^(-9), ArcTan[mag[[tmax,2,2]],mag[[tmax,2,1]]], 0],
							Norm[\[Tau]1], Norm[\[Tau]2]};
						pair=Transpose[{vars,vals}];
						info=Grid[pair,Frame->All,Alignment->Left,ItemStyle->{Automatic},Background->{{Lighter[Blue,0.7]},Lighter[Yellow,0.9]},Dividers->{True,{True,True}}];
						Row[{Show[Bgplot,trace,Mplot],info},Spacer[0]]
						];
						
	(* Evolve the M1 and M2 acc *)
	AFMDynamics[\[Alpha]G_, \[Delta]t_, tmax_, FL_, DL_, m1i_, m2i_] := Manipulate[Module[{Btot, mag, BFields, AFields, HFields, Bgplot, Mplot, trace},
						mag={{Normalize[m1i], Normalize[m2i]}};
						If[Length[BFieldDC]>0, Btot=Sum[BFieldDC[[i,1]]*BFieldDC[[i,2]],{i,1,Length[BFieldDC]}], Btot={0,0,0}];
						Do[AppendTo[mag, LLGSolver[mag[[j-1,1]], mag[[j-1,2]], Btot+FL[(j-2)*\[Delta]t], DL[(j-2)*\[Delta]t], BE, \[Alpha]G, \[Delta]t]], {j,2,tmax}];
						Bgplot = DispConfg["off"];
						Mplot=DispM[mag[[T,1]], mag[[T,2]]];Meq=mag;
						trace=Graphics3D[{{Blue, Line[mag[[1;;T,1]]]},{Red, Line[mag[[1;;T,2]]]}},Boxed->False,Axes->False,PlotRange->All,ImageSize->Medium];
						Show[Bgplot,trace,Mplot]
						],{{T, 2, "time"}, 2, tmax, 1, Appearance->"Labeled"}];
	
	(* Calculate total anisotropy field *)
	CalAns[Md_] := Module[{Beasy,Bhard},
						If[Length[EasyAxis]>0, Beasy=Sum[EasyAxis[[i,1]]*(Md . EasyAxis[[i,2]])*EasyAxis[[i,2]],{i,1,Length[EasyAxis]}], Beasy={0,0,0}];
						If[Length[HardAxis]>0, Bhard=Sum[HardAxis[[i,1]]*(Md . HardAxis[[i,2]])*HardAxis[[i,2]],{i,1,Length[HardAxis]}], Bhard={0,0,0}];
						Beasy+Bhard];
	
	(* LLG solver: Calculate M1 and M2 for next step *)
	LLGSolver[S1_, S2_, FL_, DL_, BE_, \[Alpha]_, dt_] := Module[{HG1, HG2, Ht1, Ht2, A1, A2, m1, m2},
												m1=Normalize[S1]; m2=Normalize[S2];
												Ht1=CalAns[m1]+FL+S1\[Cross]DL-BE*m2;
												Ht2=CalAns[m2]+FL+S2\[Cross]DL-BE*m1;
												HG1=\[Alpha]*(Ht1\[Cross]m1);          HG2=\[Alpha]*(Ht2\[Cross]m2);
												Ht1=\[Gamma]*(HG1-Ht1)/(1+\[Alpha]^2); Ht2=\[Gamma]*(HG2-Ht2)/(1+\[Alpha]^2);
												A1={{0, Ht1[[3]], -Ht1[[2]]},{-Ht1[[3]], 0, Ht1[[1]]},{Ht1[[2]], -Ht1[[1]], 0}};
												A2={{0, Ht2[[3]], -Ht2[[2]]},{-Ht2[[3]], 0, Ht2[[1]]},{Ht2[[2]], -Ht2[[1]], 0}};
												{MatrixExp[A1*dt] . m1, MatrixExp[A2*dt] . m2}];
	
	
	(* Magnetization expansion in local coordinates *)
	m1L = {m1xL,m1yL,1};
	m2L = {m2xL,m2yL,1};
	
	(* Tansform the Global Fields to the local coordinates of S *)
	GlobalToLocal[GFields_, S_] := Module[{xL,yL,zL=Normalize[S]}, yL=Normalize[If[{1,0,0}\[Cross]zL!={0,0,0}, {1,0,0}\[Cross]zL, {0,1,0}\[Cross]zL]]; xL=Normalize[yL\[Cross]zL];
										{GFields . xL, GFields . yL, GFields . zL}];
										
	(* Tansform the Local Fields in the local coordinates of S to the Global coordinates *)									
	LocalToGlobal[LFields_, S_] := Module[{xL,yL,zL=Normalize[S],GF}, yL=Normalize[If[{1,0,0}\[Cross]zL!={0,0,0}, {1,0,0}\[Cross]zL, {0,1,0}\[Cross]zL]]; xL=Normalize[yL\[Cross]zL];
										GF=LFields[[1]]*xL+LFields[[2]]*yL+LFields[[3]]*zL;
										{GF[[1]], GF[[2]], GF[[3]]}];
										
	(* Calculate the local Anisotropy fields *)									
	CalLocalAns[S_,Md_] := Module[{Beasy,Bhard, EasyAxisLocal, HardAxisLocal},
						If[Length[EasyAxis]>0, EasyAxisLocal=Table[{EasyAxis[[i,1]], Normalize[GlobalToLocal[EasyAxis[[i,2]], S]]}, {i,1,Length[EasyAxis]}], EasyAxisLocal={}];
						If[Length[HardAxis]>0, HardAxisLocal=Table[{HardAxis[[i,1]], Normalize[GlobalToLocal[HardAxis[[i,2]], S]]}, {i,1,Length[HardAxis]}], HardAxisLocal={}];
						If[Length[EasyAxisLocal]>0, Beasy=Sum[EasyAxisLocal[[i,1]]*(Md . EasyAxisLocal[[i,2]])*EasyAxisLocal[[i,2]],{i,1,Length[EasyAxisLocal]}], Beasy={0,0,0}];
						If[Length[HardAxisLocal]>0, Bhard=Sum[HardAxisLocal[[i,1]]*(Md . HardAxisLocal[[i,2]])*HardAxisLocal[[i,2]],{i,1,Length[HardAxisLocal]}], Bhard={0,0,0}];
						Beasy+Bhard];
	
	(* Tansform all the fields in the local coordinates of M1 and M2 *)
	LLG["1",\[Theta]1_,\[Theta]2_,\[Phi]1_,\[Phi]2_] := Module[{S1, S2, Btot, B0L1, Bex},
								S1={Sin[\[Theta]1]*Cos[\[Phi]1], Sin[\[Theta]1]*Sin[\[Phi]1], Cos[\[Theta]1]}; S2={Sin[\[Theta]2]*Cos[\[Phi]2], Sin[\[Theta]2]*Sin[\[Phi]2], Cos[\[Theta]2]};
								If[Length[BFieldDC]>0, Btot=Sum[BFieldDC[[i,1]]*BFieldDC[[i,2]],{i,1,Length[BFieldDC]}], Btot={0,0,0}];
								B0L1 = GlobalToLocal[Btot, S1];
								Bex = GlobalToLocal[LocalToGlobal[-m2L, S2],S1];
								-\[Gamma]*m1L\[Cross](B0L1 + BE*Bex + CalLocalAns[S1, m1L])];
	
	LLG["2",\[Theta]1_,\[Theta]2_,\[Phi]1_,\[Phi]2_] := Module[{S1, S2, Btot, B0L2, Bex},
								S1={Sin[\[Theta]1]*Cos[\[Phi]1], Sin[\[Theta]1]*Sin[\[Phi]1], Cos[\[Theta]1]}; S2={Sin[\[Theta]2]*Cos[\[Phi]2], Sin[\[Theta]2]*Sin[\[Phi]2], Cos[\[Theta]2]};
								If[Length[BFieldDC]>0, Btot=Sum[BFieldDC[[i,1]]*BFieldDC[[i,2]],{i,1,Length[BFieldDC]}], Btot={0,0,0}];
								B0L2 = GlobalToLocal[Btot, S2];
								Bex = GlobalToLocal[LocalToGlobal[-m1L, S1],S2];
								-\[Gamma]*m2L\[Cross](B0L2 + BE*Bex + CalLocalAns[S2, m2L])];
	
	(* Construct the LLG Matrix: dM/dt=i\[Omega]*M=[4x4 matrix]xM *)
	Mc[sublattice_,\[Theta]1_,\[Theta]2_,\[Phi]1_,\[Phi]2_,row_,col_] := Coefficient[LLG[sublattice,\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2][[row]],col,1];
	MLLG[\[Theta]1_,\[Theta]2_,\[Phi]1_,\[Phi]2_] := {
	{Mc["1",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,1,m1xL], Mc["1",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,1,m1yL], Mc["1",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,1,m2xL], Mc["1",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,1,m2yL]},
	{Mc["1",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,2,m1xL], Mc["1",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,2,m1yL], Mc["1",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,2,m2xL], Mc["1",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,2,m2yL]},
	{Mc["2",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,1,m1xL], Mc["2",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,1,m1yL], Mc["2",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,1,m2xL], Mc["2",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,1,m2yL]},
	{Mc["2",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,2,m1xL], Mc["2",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,2,m1yL], Mc["2",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,2,m2xL], Mc["2",\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,2,m2yL]}};
	
	(* Linearized the LLG *)
	Linearized[expr_]:=Simplify[expr/.{m1xL->0,m1yL->0,m2xL->0,m2yL->0}];	
	
	(* Plot the Eigenstates*)
	PlotEigen[] := Manipulate[Module[{Vals,Vecs,EqAngle,\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2,S,m1x,m1y,m2x,m2y,n1,n2,M1t,M2t,Neel,Mag,TraceM1,TraceM2,TraceM,TraceN,fig},
							EqAngle=FindGS["off"]; \[Theta]1=EqAngle[[1]]; \[Theta]2=EqAngle[[2]]; \[Phi]1=EqAngle[[3]]; \[Phi]2=EqAngle[[4]];
							{Vals,Vecs} = Eigensystem[Linearized[MLLG[\[Theta]1,\[Theta]2,\[Phi]1,\[Phi]2]]];
							S = Transpose@SortBy[Transpose[{Re[-I*Vals],Vecs}], First];
							m1x = S[[2, mode, 1]];
							m1y = S[[2, mode, 2]];
							m2x = S[[2, mode, 3]];
							m2y = S[[2, mode, 4]];
							n1 = {Sin[\[Theta]1]*Cos[\[Phi]1], Sin[\[Theta]1]*Sin[\[Phi]1], Cos[\[Theta]1]};
							n2 = {Sin[\[Theta]2]*Cos[\[Phi]2], Sin[\[Theta]2]*Sin[\[Phi]2], Cos[\[Theta]2]};
							M1t[t_,amp_] := LocalToGlobal[amp*{Re[m1x*Exp[I*t]], Re[m1y*Exp[I*t]], 0},n1]+n1;
							M2t[t_,amp_] := LocalToGlobal[amp*{Re[m2x*Exp[I*t]], Re[m2y*Exp[I*t]], 0},n2]+n2;
							Neel[t_,amp_]:= (M1t[t,amp]-M2t[t,amp])/2;
							Mag[t_,amp_] := (M1t[t,amp]+M2t[t,amp])/2;
							TraceM1 = Table[M1t[dt, Amp],{dt,0,2*Pi,2*Pi/100}];
							TraceM2 = Table[M2t[dt, Amp],{dt,0,2*Pi,2*Pi/100}];
							TraceM  = Table[Mag[dt, Amp],{dt,0,2*Pi,2*Pi/100}];
							TraceN  = Table[Neel[dt,  Amp],{dt,0,2*Pi,2*Pi/100}];
							fig=Graphics3D[{
							If[nl == 0,{Blue,Thin, Line[TraceM1]}],
							If[nl == 0,{Red, Thin, Line[TraceM2]}],
							If[nl == 0,{Blue,Thick,Arrow[{{0,0,0},M1t[T, Amp]}]}],
							If[nl == 0,{Red, Thick,Arrow[{{0,0,0},M2t[T, Amp]}]}],
							If[nl == 0,{Black,Text[Style["m1",12,Italic],M1t[T, Amp],{1.2,1.2}]}],
							If[nl == 0,{Black,Text[Style["m2",12,Italic],M2t[T, Amp],{1.2,1.2}]}],
							If[nl == 1,{Blue, Thick,Arrow[{{0,0,0},Ms*Mag[T, Amp]}]}],
							If[nl == 1,{Red,Thick,Arrow[{{0,0,0},Ns*Neel[T,Amp]}]}],
							If[nl == 1,{Blue, Thin, Line[Ms*TraceM]}],
							If[nl == 1,{Red,Thin, Line[Ns*TraceN]}],
							If[nl == 1,{Black,Text[Style["N",12,Italic],Ns*Neel[T, Amp],{1.2,1.2}]}],
							If[nl == 1,{Black,Text[Style["M",12,Italic],Ms*Mag[T, Amp],{1.2,1.2}]}]
							},
							Boxed->False,Axes->False,Ticks->None,ImageSize->Large,ImagePadding->0,PlotRange->All
							];
							Show[DispConfg["off"],fig]
							],
							{{Amp, 1, "Enlarge"}, 0.01, 10, Appearance->"Labeled"},
							{{T, 0, "Time"}, 0, 100, Appearance->"Labeled"},
							{{mode, 4, "Mode"}, {4->"\[Alpha]", 3->"\[Beta]"}, SetterBar},
							{{nl, 0, "Neel Vector"}, {0->"off", 1->"on"}, SetterBar},
							Dynamic[If[nl==1,Control[{{Ms,1,"Enlarge m"}, 0.01,100,Appearance->"Labeled"}], Invisible[{{Ms,None},ControlType->None}]]],
							Dynamic[If[nl==1,Control[{{Ns,1, "Enlarge N"},0.01,100,Appearance->"Labeled"}], Invisible[{{Ns,None},ControlType->None}]]]];


End[] 

(* Ending infos*)
Print["AFMVisualize loaded successfully." <> " Version: " <> AFMVersion];
Print["Developed by Junyu Tang (UCR)."]
Print["Type ?AFMVisualize`* to see all vriables and available functions."];
Print["For more infos, visit: https://github.com/Rh0-aias/AFMVisualize"];

EndPackage[]
