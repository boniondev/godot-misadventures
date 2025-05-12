extends Node

var _SAVEFOLDERNAME    : String = "FCabinet_saves"
var _SAVEFOLDERPATH    : String = "user://" + _SAVEFOLDERNAME
var _SAVEFILEPATH      : String = _SAVEFOLDERPATH + "/"
var file               : FileAccess

func check_all() -> void:
	check_dir(_DIRTYPE.LOG)
	check_dir(_DIRTYPE.CONFIG)

func _notification(what : int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and file != null:
		file.close()

#region Directory creation and checking

enum _DIRTYPE{
	SAVE,
	LOG,
	CONFIG
}

func make_dir(path : String):
	var err = DirAccess.make_dir_absolute(path)
	if err != OK: 
		OS.alert("Unable to write to \"" + path + "\", please grant permission to write to that folder")
	else:
		return OK


func check_dir(which : int) -> int:
	var path : String
	match which:
		_DIRTYPE.SAVE:
			path = _SAVEFOLDERPATH
		_DIRTYPE.LOG:
			path = _LOGFOLDERPATH
		_DIRTYPE.CONFIG:
			path = _CONFIGFOLDERPATH
	var exists = DirAccess.dir_exists_absolute(path)
	if !exists:
		return make_dir(path)
	else:
		return OK
#endregion


#region Logging
const _LOGFOLDERNAME     : String = "FCabinet_logs"
const _LOGFOLDERPATH     : String = "user://" + _LOGFOLDERNAME
const _LOGFILESPATH      : String = _LOGFOLDERPATH + "/"
#var _MAXLOGFILES         : int    = 5 unused for now

enum LOGSEVERITY {
	## Every event that occurs frequently or recursively
	DEBUG,
	## An event that is useful to log but doesn't happen often, I.E one time signal emits
	INFO,
	## An event that was not supposed to happen, but doesn't affect the game in any way
	WARNING,
	## An event that affects things under the hood and may or may not cause problems
	ALERT,
	## An event that stops the game from working or requires immediate action. Usually preludes the closing of the game.
	ERROR
}
var LOGSEVERITYDICT : Dictionary = {
	LOGSEVERITY.DEBUG   : "DEBUG",
	LOGSEVERITY.INFO    : "INFO",
	LOGSEVERITY.WARNING : "WARNING",
	LOGSEVERITY.ALERT   : "ALERT",
	LOGSEVERITY.ERROR   : "ERROR"
}

enum LOGTYPE {
	## Sent or received data or messages
	MULTIPLAYERIO,
	## Connection or disconnection of peers
	MULTIPLAYERDIAGNOSTIC
}
var LOGTYPEDICT : Dictionary = {
	LOGTYPE.MULTIPLAYERIO         : "MULTIPLAYERIO",
	LOGTYPE.MULTIPLAYERDIAGNOSTIC : "MULTIPLAYERDIAGNOSTIC"
}

enum MULTIPLAYEREVENTIO {
	SENT,
	RECEIVED
}
var MULTIPLAYEREVENTIODICT : Dictionary = {
	MULTIPLAYEREVENTIO.SENT       : "SENT",
	MULTIPLAYEREVENTIO.RECEIVED   : "RECEIVED",
}

enum MULTIPLAYEREVENTDIAG {
	CONNECTED,
	DISCONNECTED
}
var MULTIPLAYEREVENTDIAGDICT : Dictionary = {
	MULTIPLAYEREVENTDIAG.CONNECTED    : "CONNECTED TO",
	MULTIPLAYEREVENTDIAG.DISCONNECTED : "DISCONNECTED FROM"
}

enum FILENAME {
	MULTIPLAYERSERVER,
	MULTIPLAYERCLIENT
}
var FILENAMEDICT : Dictionary = {
	FILENAME.MULTIPLAYERSERVER : "multiplayer_server",
	FILENAME.MULTIPLAYERCLIENT : "multiplayer_client"
}

func add_log(logcontents : Dictionary, filename : int) -> void:
	check_dir(_DIRTYPE.LOG)
	if FileAccess.file_exists(_LOGFILESPATH + FILENAMEDICT.get(filename) + ".log"):
		file = FileAccess.open(_LOGFILESPATH + FILENAMEDICT.get(filename) + ".log",FileAccess.READ_WRITE)
		file.seek_end()
	else:
		file = FileAccess.open(_LOGFILESPATH + FILENAMEDICT.get(filename) + ".log",FileAccess.WRITE)
	if file == null:
		OS.alert("logging error")
		return
	file.store_string(str(Time.get_ticks_msec()) + "|")
	file.store_string("[" + Time.get_time_string_from_system() + "]" + "|")
	file.store_string(LOGSEVERITYDICT.get(logcontents.get("LOGSEVERITY")) + "|")
	file.store_string(LOGTYPEDICT.get(logcontents.get("LOGTYPE")) + ":")
	match logcontents.get("LOGTYPE"):
		LOGTYPE.MULTIPLAYERIO:
			file.store_string(handlemultiplayerIOlog(logcontents))
		LOGTYPE.MULTIPLAYERDIAGNOSTIC:
			file.store_string(handlemultiplayerdiagnosticlog(logcontents))
	file.store_string("\n")
	file.close()

## @experimental
func add_log_new(contents : String, severity : int, filename : String) -> void:
	check_dir(_DIRTYPE.LOG)
	if FileAccess.file_exists(_LOGFILESPATH + ".log"):
		file = FileAccess.open(_LOGFILESPATH + ".log",FileAccess.READ_WRITE)
		file.seek_end()
	else:
		file = FileAccess.open(_LOGFILESPATH + filename + ".log",FileAccess.WRITE)
	if file == null:
		OS.alert("logging error")
		return
	file.store_string(str(Time.get_ticks_msec()) + "|")
	file.store_string("[" + Time.get_time_string_from_system() + "]" + "|")
	file.store_string(LOGSEVERITYDICT.get(severity) + "|")
	file.store_string(contents)
	file.store_string("\n")
	file.close()

func add_multi_diag_log_conn(peerid : int, event : int, otherpeer : int, isserver : bool, severity : int = LOGSEVERITY.INFO) -> void:
	var logtext  : String = "MULTIPLAYERDIAGNOSTIC:" + str(peerid) + " " + MULTIPLAYEREVENTDIAGDICT.get(event) + " " + str(otherpeer)
	if otherpeer == 1 and !isserver:
		logtext = logtext + "(SERVER)"
	var filename : String
	if isserver and otherpeer == 1:
		filename = "multiplayer_server"
		logtext = logtext + "(ME)"
	else:
		filename = "multiplayer_client"
	add_log_new(logtext,severity,filename)
	

func handlemultiplayerdiagnosticlog(multiplayerlog : Dictionary) -> String:
	var parsedlog = ""
	if multiplayerlog.has("PEERID"):
		parsedlog = parsedlog + str(multiplayerlog.get("PEERID")) + " "
		parsedlog = parsedlog + multiplayerlog.get("EVENT")
	return parsedlog

func handlemultiplayerIOlog(multiplayerlog : Dictionary) -> String:
	var parsedlog = ""
	parsedlog = parsedlog + str(multiplayerlog.get("PEERID")) + " "
	parsedlog = parsedlog + MULTIPLAYEREVENTIODICT.get(multiplayerlog.get("EVENT")) + " "
	match typeof(multiplayerlog.get("WHAT")):
		TYPE_STRING:
			parsedlog = parsedlog + multiplayerlog.get("WHAT")
		TYPE_VECTOR2:
			parsedlog = parsedlog + "Vector2" + "(" + str(multiplayerlog.get("WHAT").x) + "," +  str(multiplayerlog.get("WHAT").y) + ")" + " "
		#more string conversions go here
	match MULTIPLAYEREVENTIODICT.get(multiplayerlog.get("EVENT")):
		"RECEIVED":
			parsedlog = parsedlog + "FROM "
		"SENT":
			parsedlog = parsedlog + "TO "
	parsedlog = parsedlog + str(multiplayerlog.get("WHOID"))
	return parsedlog
#endregion


#region Configuration file handling and creation
const _CONFIGFOLDERNAME  : String = "FCabinet_configs"
const _CONFIGFOLDERPATH  : String = "user://" + _CONFIGFOLDERNAME
const _CONFIGFILESPATH   : String = _CONFIGFOLDERPATH + "/"

const _SYSTEMSETTINGSFILENAME : String = "systemsettings.json"


#endregion
