class WindowWatcher {
	
	__new(vd := ""){
		Bindings := {}
		this.vd := vd
	}
	
	AddRule(WinTitle := "",ExcTitle := "",OpenFunc := "", CloseFunc := ""){
		this.Bindings[WinTitle] := new Rule(WinTitle, ExcTitle, OpenFunc, CloseFunc, this.vd)
	}
	
	DeleteRule(WinTitle){
		this.Bindings[WinTitle].Stop()
		this.Bindings.Delete(WinTitle)
	}
	
	SuspendRule(WinTitle){
		this.Bindings[WinTitle].state := 0
	}
	
	ResumeRule(WinTitle){
		this.Bindings[WinTitle].state := 1
	}
	
	SuspendAll(){
		for Key in This.Bindings
			this.SuspendRule(Key)
	}
	
	ResumeAll(){
	for Key in This.Bindings
			this.ResumeRule(Key)
	}
	
	DeleteAll(){
	for Key in This.Bindings
			this.DeleteRule(Key)
	}
}

Class Rule {
	
	__new(WinTitle := "", ExcTitle := "", OpenFunc := "", CloseFunc := "", vd := ""){ 
		this.state := 1 							;Make PollWindows trigger open and close functions
		this.windows := {}						;Prepare PollWindows array
		this.WinTitle := (WinTitle = "All") ? ("") : (WinTitle)	;Trick to Make PollWindows get all windows
		this.ExcTitle := ExcTitle				;Set our Exclusion WinTitle
		this.OpenFunc := Func(OpenFunc)			;Bind our OpenFunc
		this.CloseFunc := Func(CloseFunc)		;Bind our CloseFunc
		this.VD := vd
		if !(this.VD = ""){
			this.Desktop := this.VD.CurrentDesktop
		}
		else{
			this.vd.CurrentDesktop := 1
			this.Desktop := 1
		}
		this.PollFunc := ObjBindMethod(this, "PollWindows") ;Half of a dirty trick to allow use of a method with SetTimer
		this.Start()								;Start Poll Windows
	}
	
	Start(){										;Start Polling Windows
		Poll := this.PollFunc						;Second Half of dirty SetTimer trick
		SetTimer, % Poll
	}
	
	Stop(){										;Stop Polling Windows
		Poll := this.PollFunc						;Second Half of dirty SetTimer trick
		SetTimer, % Poll, Delete
	}
	
	PollWindows(){
		WinGet, Wins, List, % this.WinTitle 	;Get a list of selected window IDs as a pseudo-array
		newWindows := Object()					;Create an object to store the current open windows
		Loop, %Wins%								;Establish Array of Windows That Excludes ExcTitle Windows
		{
			this.PollDesktops()
			prevdesktop := this.Desktop
			WindowID := Wins%A_Index% 			
			if(this.ExcTitle && winexist(this.ExcTitle . " ahk_id " . WindowID)){
				Continue							;If a window matches ExcTitle, Skip it.
			}
			WinGet,WinExe,ProcessName,ahk_id %WindowID% ;Get the Exe name of loop index window
			WinGetClass,WinClass,ahk_id %WindowID% 	;Get the Class Name of the loop index window
			ExeClass := [WinExe, WinClass] 		;Assign the Exe Name and Class Name to a holding array	
			newWindows[WindowID] := ExeClass 	;Add the ExeClass array as a value to the object as a value for key WindowID
			this.PollDesktops()
			if (prevdesktop != this.Desktop){
				return
			}
		}
		
		for WindowID in newWindows {
			if (!this.windows[this.Desktop][WindowID] && this.state){ ;If window is newly opened & the State flag is set
				this.OpenFunc.Call(WindowID)	;Call the Assigned Open Function
			}
		}
		
		for WindowID, ExeClassArray in this.windows[Desktop] {	;For each previously existing window
			if (!newWindows[WindowID] && this.state){	;If the Window Doesn't exist anymore && the State Flag is set
				this.CloseFunc.Call(WindowID,ExeClassArray) ; Call the Assigned Close Function
			}
		}	
		this.PollDesktops()
		this.windows[This.Desktop] := newWindows				;Store the Open Windows for the next Window Poll 
		this.PollDesktops()
	}
	
	PollDesktops(){
		if !(this.VD = ""){
			if (this.Desktop != this.VD.CurrentDesktop){
				this.Desktop := this.VD.CurrentDesktop ; Update Desktops
			}
			this.VD.updateGlobalVariables()
		}
		else{
			this.Desktop := 1
		}
	}
}
