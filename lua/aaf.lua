//AutoAddFile 

AAF = {}

AAF.enable    = true

AAF.addon	  = true //allow addons including (only workshop!) //8192 MAX includes
AAF.other 	  = true //allow sound/models folders to include
AAF.update    = true //autoupdate
AAF.massages  = true //massages in console

//Where to search custom resources:
AAF.include = 
{
    'sound',
    'models',
    'materials',
    'resource',
}

//Workshop id or full name of file
AAF.blacklist =
{
	'id',
}

//-----------------\\
--don't touch below--
if !file.Exists('aaf_settings.txt','DATA') then
	file.Write('aaf_settings.txt',util.TableToJSON(AAF))
end

//SHIT CODE START
local function Save(x,y,pl)
	if !pl:IsAdmin() then pl:ChatPrint('[AAF] Only Admin can change AAF Setting!') return end
	AAF[x] = !AAF[x]
	pl:ChatPrint('[AAF] '..y..' are now '..Either(AAF[x],'Enabled!','Disabled!'))
	file.Write('aaf_settings.txt',util.TableToJSON(AAF))
end

AAF = util.JSONToTable(file.Read('aaf_settings.txt'))

concommand.Add('aaf_enable',  function(pl) Save('enable','Addon',pl)            end)
concommand.Add('aaf_addon',   function(pl) Save('addon','Addons include',pl)    end)
concommand.Add('aaf_other',   function(pl) Save('other','Resources include',pl) end)
concommand.Add('aaf_massages',function(pl) Save('massages','Massages',pl)       end)
concommand.Add('aaf_update',function(pl)   Save('update','Auto Appdata',pl)     end)

concommand.Add('aaf_addid',function(pl) 
	AAF.blacklist[id] = true 
	pl:ChatPrint('[AAF] '..id..' workshop id added to blacklist!') 
	file.Write('aaf_settings.txt',util.TableToJSON(AAF))
end)
	
concommand.Add('aaf_removeid',function(pl) 
	AAF.blacklist[id] = nil        
	pl:ChatPrint('[AAF] '..id..' workshop id removed to blacklist!') 	
	file.Write('aaf_settings.txt',util.TableToJSON(AAF))
end)
//SHIT CODE END

if !AAF.enable or game.SinglePlayer() then return end

function AAF.Msg(what) 
	if !AAF.massages then return end
	MsgC(Color(125,125,255),'[AAF]',Color(225,125,155),' '..what..'\n')
end

AAF.Try    = 0
AAF.addons = file.Find('addons/*','MOD')
AAFData    = util.JSONToTable(file.Read('aaf.dat') or '')

local debu = ''

function AAF.AddInit(tbl)
	local function read(path)
		path=path or ''
		local fs,ds = file.Find(path..'*','MOD')
		for k,f in pairs(fs) do
			if (table.HasValue(tbl,path..f) or tbl[path..f]) or AAF.blacklist[path..f] then 
				continue end
			AAF.Msg('Adding '..path..f)
			resource.AddSingleFile(path..f)
			debu = debu..path..f..'\n'
		end 
		for k,d in pairs(ds) do
			read(path..d..'/') 
		end
	end
	
	AAF.Msg('Adding files, server may freeze for few seconds')
	
	if AAF.addon then
		for v,k in pairs(AAF.addons) do
			local buff = ''
			local st   = #k-12
			for i=st,#k-4 do buff = buff..k[i] end
			resource.AddWorkshop(buff)
			AAF.Msg('Adding addon '..k)
		end
	end

	if AAF.other then
		for i = 1,#AAF.include do
			AAF.Msg('Reading '..AAF.include[i])
			read(AAF.include[i]..'/')
		end
	end
	
	file.Write('aaf_files.txt',debu)
end

function AAF.LoadGit()
    http.Fetch('https://raw.githubusercontent.com/Denzeriko/AAF/master/data/aaf.dat',
        function(data)
            if #data < 30 then 
                if AAF.Try >= 2 then AAF.Msg('Something bad happend! Abort!') return end 
                AAF.Try = AAF.Try + 1 AAF.Msg('File error! Trying to Load again') AAF.LoadGit() 
            else
                AAF.Msg('Data secussfully loaded!')
                file.Write('aaf.dat',data)
                AAFData = util.JSONToTable(file.Read('aaf.dat'))
                AAF.AddInit(AAFData)
            end
        end,
        function(err)
			AAF.Msg(err)
            AAF.Msg('Github dont answer or file dont exists!')
        end
    )
end

function AAF.CheckUpdate()
	if !AAF.update then return end
	http.Fetch('https://raw.githubusercontent.com/Denzeriko/AAF/master/data/aaf.dat',function(data)
		local a = util.JSONToTable(data)[1]
		local b = util.JSONToTable(file.Read('aaf.dat'))[1]
		if a != b then
			AAF.Msg('New version is avaible. Downloading data...')
			AAF.LoadGit()
		end
	end)
end

//if GetConVar("sv_downloadurl"):GetString() != '' then
//	AAF.Msg(GetConVar("sv_downloadurl"):GetString()..' Detected FastDL! Aborting AAF!')
//return end

if !AAFData then 
    AAF.Msg('No data found, trying to load from github') 
    AAF.LoadGit()
else
	AAF.CheckUpdate()
	AAF.AddInit(AAFData)
end