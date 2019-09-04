program define send 
*Alessandro Rosi*
version 14.0
syntax, [to(string)  Message(string) Path(string) From(string) Icon(string) Title(string)] [profiles pause time ACCount DIRectory setuser setsender delsender deluser QUIte]

	
* CHECK PROFILES *
		if "`directory'"=="directory" {
			di as text "Receiver profiles:"
			dir "`c(sysdir_personal)'send/user_*"	
			di as text "Sender profile:"
			dir "`c(sysdir_personal)'send/sender.do*"	
		exit
		}	
		
local Sline "-----------------------------------------------------------------------------------------------"
local Dline "==============================================================================================="



* SHOW PROFILE SETTINGS *
		if "`profiles'"=="profiles" {
			local flist : dir "`c(sysdir_personal)'send/" files "user_*.do", respectcase
			qui include "`c(sysdir_personal)'send/sender.do"
			di ""
			di ""
			di as text "`Dline'"
			di as text "Sender profile"
			di as text ""
			di as text "Sender user name: " as result "`SENDER_NAME'"
			di as text "Token: " as result "`TOKEN'"

			di ""
			di ""
			di as text "`Dline'"
			di as text "Receiver profiles" 
			di ""
			foreach fname of local flist {
				qui include "`c(sysdir_personal)'send/`fname'"
				local fuser=substr("`fname'",6,.)
				local fuser=substr( "`fuser'" , 1, strlen( "`fuser'") - 3)
				di as result "`fuser'"
				di as text "User/channel name: " as result "`u_val_`fuser''"
				di as text "Url: " as result "`URL_`fuser''"
				di as text "User name (channel) in slak: " as result "`FILE_DESTIN_`fuser''"
				di as text ""
			}
		exit
		}

		
* SET USER *
	if "`setuser'"=="setuser" {
		di as text `"Enter:	["' as result `"new"' as text`"] to create/replace a receiver profile;"'
		di as text `"		["' as result `"imp"' as text`"] to import an existing user_"name".do;"' 
		di as text `"		["' as result `"exit"' as text`"] to quit setuser."'
		di ">" _request(newORimport)
		
			if "$newORimport"=="new" {
				di as text "`Sline'"
				di as text "Enter user/channel profile (without space, content of the option 'to()'): " _request(new_user)
				di as text "Enter user/channel user name (full name, nickname, whatever; if you are setting your profile use the sender user name): " _request(user_name)
				di as text "Enter user/channel URL: " _request(new_url)
				di as text `"Enter user/channel account name in Slack (without "#"): "' _request(new_fdest)
				di ""
			
				cap log close
				qui {
					cap log using "`c(sysdir_personal)'send/user_${new_user}.do", text 
						if _rc==0 {
							noi di `"local u_val_${new_user} "${user_name}""'
							noi di `"local URL_${new_user} "${new_url}""'
							noi di `"local FILE_DESTIN_${new_user} "${new_fdest}""'
					cap log close		
						di ""
						noi di as text "`Dline'"
						noi display as text "User profile: " as input "user_$new_user.do" as text " saved in: `c(sysdir_personal)'send" 
						noi di as text "`Sline'"
						noi display as text "User name: " as input "$new_user"
						noi display as text "URI url: " as input "$new_url"
						noi display as text "file destination: " as input "$new_fdest"
						noi di as text "`Dline'"
					exit
					}
				}
				if _rc==602 {
					cap log close
					di as error "user profile already exist, do you want to replace? [y] [n]" _request(confirm)
					if "$confirm"=="y" { 				
						qui {
							log using "`c(sysdir_personal)'send/user_${new_user}.do", text replace
								noi di `"local u_val_${new_user} "${user_name}""'
								noi di `"local URL_${new_user} "${new_url}""'
								noi di `"local FILE_DESTIN_${new_user} "${new_fdest}""'
							cap log close
								di ""
								noi di as text "`Dline'"
								noi display as text "User profile: " as input "user_$new_user.do" as text " saved in: `c(sysdir_personal)'send" 
								noi di as text "`Sline'"
								noi display as text "User name: " as input "$new_user"
								noi display as text "URI url: " as input "$new_url"
								noi display as text "file destination: " as input "$new_fdest"
								noi di as text "`Dline'"
							exit
						}
					}
					else if "$confirm"=="n" exit
					else if "$confirm"!="y" | "$confirm"!="n" di as error "entry: $confirm not allowed" 
				}				
			}	
			else if "$newORimport"=="imp" {
				di as result "Important: this will replace existing profile with the same user_[name].do"
				di as text `"path: "' _request(new_pathProfile)
				cap copy $new_pathProfile "`c(sysdir_personal)'send/", replace
				di as text "`Sline'"
				display as text "User profile: " as input `"$new_pathProfile"'
				di as text " saved in: " as input "`c(sysdir_personal)'send" 
				di as text "`Sline'"
				noi di ""
				exit
			}
			else if  "$newORimport"=="exit" exit
			else if "$newORimport"!="n" | "$newORimport"!="i" {
			di as error "entry: $newORimport not allowed"
			exit
		}
		
		*clear global macros *	
		cap macro drop newORimport 
		cap macro drop confirm 
		cap macro drop new_user 
		cap macro drop new_fdest 
		cap macro drop new_url 
		cap macro drop new_pathProfile
		cap macro drop user_name
	exit
	}

	
* DELETE USER *
		if "`deluser'"=="deluser" {
			di ""
			di as text "`Sline'"
			di as text "Enter user/channel name profile: " _request(del_user)
			di as text "Do you want to delete " as result "$del_user" as text " ? [y] [n] " _request(confirm)
			if "$confirm"=="y" {
				cap erase `c(sysdir_personal)'send\user_$del_user.do
				if _rc != 0 {
					di as err "user " as result " $del_user" as err " not found"
					di as text "`Sline'"
					di ""
				exit
				}
				
				else if _rc == 0 {
					di as text "User: " as result " $del_user" as text " deleted"
					di as text "`Sline'"
					di ""
				exit
				}
			}	
			else if "`confirm'"!="y" {
				di as err "user " as result " $del_user" as err " not deleted"
				di as text "`Sline'"
				di ""
			exit
			}
		cap macro drop del_user
		}		

		
* SET SENDER *
		if "`setsender'"=="setsender" {	
				di as text `"Enter:	["' as result `"new"' as text`"] to create/replace the sender profile;"'
				di as text `"		["' as result `"imp"' as text`"] to import an existing sender.do;"' 
				di as text `"		["' as result `"exit"' as text`"] to quit setsender."'
				di ">" _request(newORimport)

			if "$newORimport"=="new" {
				capture confirm file "`c(sysdir_personal)'send/sender.do"
					if _rc==0 {
					di as error "Sender profile already exist, do you want to repalce? [y] [n]" _request(confirm)
						if "$confirm"=="y" {
							di as text "`Sline'"
							di as text "Enter sender user name. Can be your slack user name (full name) or a nick name: " _request(new_ntoken)
							di as text "Enter slack account token: " _request(new_token)
							di ""		
							cap log close
							qui {
							cap	log using "`c(sysdir_personal)'send/sender.do", text replace
								noi di `"local SENDER_NAME "${new_ntoken}""'
								noi di `"local TOKEN "${new_token}""'
							cap log close
								noi di ""
								noi di as text "`Dline'"
								noi display as text "Sender profile: " as input "sender.do" as text " saved in: `c(sysdir_personal)'send" 
								noi di as text "`Sline'"
								noi display as text "User name token: " as input "$new_ntoken"
								noi display as text "Token: " as input "$new_token"
								noi di as text "`Dline'"
								exit
							}				
						}
						else if "$confirm"=="n" exit
						else if "$confirm"!="y" | "$confirm"!="n" di as error "entry: $confirm not allowed" 
					}
				else if _rc!=0 {
				cap log close
				qui {		
					cap	log using "`c(sysdir_personal)'send/sender.do", text replace
					noi di `"local SENDER_NAME "${new_ntoken}""'
					noi di `"local TOKEN "${new_token}""'
					cap log close
					noi di ""
					noi di as text "`Dline'"
					noi display as text "Sender profile: " as input "sender.do" as text " saved in: `c(sysdir_personal)'send" 
					noi di as text "`Sline'"
					noi display as text "User name token: " as input "$new_ntoken"
					noi display as text "Token: " as input "$new_token"
					noi di as text "`Dline'"
					exit
					}
				}
			}
			else if "$newORimport"=="imp" {
				di as result "Important: this will replace existing sender.do profile"
				di as text `"path: "' _request(new_pathProfile)
				cap copy $new_pathProfile "`c(sysdir_personal)'send/", replace
				di as text "`Sline'"
				display as text "User profile: " as input `"$new_pathProfile"'
				di as text " saved in: " as input "`c(sysdir_personal)'send" 
				di as text "`Sline'"
				noi di ""
			exit
			}
			
			else if  "$newORimport"=="exit" {
			exit
			}
			else if "$newORimport"="new" | "$newORimport"!="imp" | "$newORimport"!="exit"{
			di as error "entry: $newORimport not allowed"
			exit
			}
			
		*clear global macros *	
		cap macro drop newORimport
		cap macro drop confirm 
		cap macro drop new_ntoken 
		cap macro drop new_token 
		cap macro drop new_pathProfile
	exit
	}

	
* DELETE SENDER *
	    if "`delsender'"== "delsender" {
			di ""
			di as text "`Sline'"
			di as text "Do you want to delete " as result "the sender user profile" as text " ? [y] [n] " _request(confirm)
			if "$confirm"=="y" {
				cap erase `c(sysdir_personal)'send\sender.do
				if _rc != 0 {
					di as err "Sender profile not found"
					di as text "`Sline'"
					di ""
				exit
				}
				
				else if _rc == 0 {
					di as text "Sender profile deleted"
					di as text "`Sline'"
					di ""
				exit
				}
			}	
			else if "`confirm'"!="y" {
				di as err "Sender profile not deleted"
				di as text "`Sline'"
				di ""
			exit
			}
	cap drop macro confirm	
		}			

		
* LOAD USER PROFILE *
		cap qui include "`c(sysdir_personal)'send/sender.do"
			if _rc==601 {
				di as error "	Sender profile not found in:"
				di as error "	`c(sysdir_personal)'send/user_`to'.do" 
				exit
			}
	
		cap qui include "`c(sysdir_personal)'send/user_`to'.do" 
			if _rc==601 {
				di as error "	Profile" as result " `to'" as error " not found in:"
				di as error "	`c(sysdir_personal)'send/user_`to'.do" 
				exit
			}
				
		local receiver "`u_val_`to''"
		local url "`URL_`to''" 
		local fdest "`FILE_DESTIN_`to''" 
		local token "`TOKEN'"
		local sender "`SENDER_NAME'"
				
		if "`sender'"=="`receiver'" local sender_user "me"
			else if "`sender'"!="`receiver'" local sender_user "`SENDER_NAME'" 
		if "`message'"!="" local message_opt "on" 
			else local message_opt "off"
		if "`path'"!="" local sendfile "on"
			else local sendfile "off"
		if "`icon'"=="" local icon_e "null"
			else qui include "`c(sysdir_personal)'send/icon.do"	
				
		if "`acc'"=="acc" local account " (@`c(username)')"
		if "`from'"!="" local from "- (`from')"
		if "`time'"!="" local time "($S_TIME) "
		if "`pause'"!="" local paused " (paused)"
	
	
* SEND MESSAGE *
		if "`message_opt'"=="off" noi di ""
		else if "`message_opt'"=="on" {

***********************************************************************************************************************************************************************************************************************	
! powershell -Command Invoke-WebRequest -Body(ConvertTo-Json -Compress -InputObject @{'username'='`sender_user'`acc' `from''; 'text'='`time' `message'`paused''; 'icon_emoji' = ':`icon_e':'}) -Method Post -Uri `url'
***********************************************************************************************************************************************************************************************************************
		
		if "`quite'"=="quite" {
			noi di ""
		}
		else {
			noi di as result "Sender profile"
			noi di as text "	Sender name: " as result "`SENDER_NAME'"
			noi di as text "	User token: " as result "`TOKEN'"
			noi di ""
			noi di as result "`to' (receiver)"
			noi di as text "	User name: " as result "`u_val_`to''"
			noi di as text "	User URL: " as result "`URL_`to''"
			noi di as text "	File destination: " as result "`FILE_DESTIN_`to''"
			noi di ""
		}	
		noi di as text "`Dline'"
		noi display as result "`sender_user' (@`c(username)') `from'" as text " to: " as result "`to'" 
		noi di as text "message: " as result `""`message'""'
		noi di as text "`Dline'"

		}
		
		
* SEND FILE *
		if "`sendfile'"=="off" noi di as input "" 
		else if "`sendfile'"=="on" {
		
*************************************************************************************************************
! powershell send-slackfile -token `token' -channel '@`fdest'' -path `path' -title '`title' `time' `paused''
*************************************************************************************************************
		
		if "`quite'"=="quite" {
			noi di ""
		}
		else {
			noi di as result "Sender profile"
			noi di as text "	Sender name: " as result "`SENDER_NAME'"
			noi di as text "	User token: " as result "`TOKEN'"
			noi di ""
			noi di as result "`to' (receiver)"
			noi di as text "	User name: " as result "`u_val_`to''"
			noi di as text "	User URL: " as result "`URL_`to''"
			noi di as text "	File destination: " as result "`FILE_DESTIN_`to''"
			noi di ""
		}
		noi di as text "File sent from: " as result "`sender_user' (@`c(username)')" as text  " to: " as result "`fdest'" as text " title: " as result "`title'" as input " `time'" 
		di as text "path: " as input "`path'"
		}

		
* PAUSE *
		if "`pause'"=="pause" shell pause

end

