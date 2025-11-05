pickedUp = false
clickPlayerColor = ""
newX = 0
newZ = 0
facX = 1
facZ = 1
posX = 0
maxX=0
posZ=0
maxZ=0
hip=0
rngMov=0
posY=0
txtMax = ""
colorLinea = Color(0.10,0.10,0.09)
state = nil
baseModel = nil
mtoi = 0.0393701
--GUIDModel = ""
function onPickUp(cp)
clickPlayerColor = cp
--print(clickPlayerColor)
pickedUp = true
startLuaCoroutine(self, "movModel")
end

function movModel()
objModel = getObjectFromGUID(GUIDNodPrev)
posX = objModel.getPosition().x
posZ = objModel.getPosition().z
posY = objModel.getPosition().y
state = objModel.getTable("state")
baseModel = objModel.getTable("state").base.x

maxX = posX + rngMov
maxZ = posZ + rngMov

while (pickedUp == true) do
posicionLock()
coroutine.yield(0)
end
return 1
end


function posicionLock()

	
	        mouseX = self.getPosition().x  
        	mouseZ = self.getPosition().z  
		newX = mouseX
		newZ = mouseZ
		FZ=1
		SX=0
		SZ=0
		--print("X:"..mouseX.."|Z:"..mouseZ)
		if math.sqrt(((mouseX-posX)*(mouseX-posX)) + ((mouseZ-posZ)*(mouseZ-posZ))) > rngMov then
			--print("dentro")
				m=(mouseZ-posZ)/(mouseX-posX)
				A=(m*mouseX)-mouseZ+posZ
				T1=(1+(m*m))
				T2=(-2*posX)+(-2*A*m)
				T3=(posX*posX)+(A*A)-(rngMov*rngMov)
				S1X = ((-1*T2)+math.sqrt((T2*T2)-(4*T1*T3)))/(2*T1)
				S2X = ((-1*T2)-math.sqrt((T2*T2)-(4*T1*T3)))/(2*T1)
				if mouseX > posX then SX = math.max(S1X,S2X) else SX = math.min(S1X,S2X) end
				if mouseZ < posZ then FZ = -1 else FZ = 1 end
				SZ = (math.sqrt((rngMov*rngMov)-((SX-posX)*(SX-posX)))*FZ)+posZ
				--print("pX:"..posX.."|pZ:"..posZ.."|m:"..m.."|A:"..A.."|T1:"..T1.."|T2:"..T2.."|T3:"..T3.."|FZ:"..FZ)
				newX = SX
				newZ = SZ
				--print("X:"..mouseX.."|newX:"..newX.."|Z:"..mouseZ.."|newZ:"..newZ)
				self.setPosition({x=newX, y=self.getPosition().y, z=newZ})
				self.setVelocity({0,0,0})
        			self.setAngularVelocity({0,0,0})
				--Wait.frames(function() print("corrigio") end, 5)
		else
			--print("fuera")
		end
		self.setRotation({0,0,0})
		refrescaVectores()
		refrescaTextoRango()

end

function onDropped(cp)
if pickedUp == true then
pickedUp = false
self.setPosition({x=newX, y=self.getPosition().y, z=newZ})
self.setVelocity({0,0,0})
self.setAngularVelocity({0,0,0})
self.setRotation({0,0,0})
--self.setDescription("X:"..newX.."|Z:"..newZ)
refrescaVectores()
end
end	

function refrescaVectores()
	
	result = {}
	newLines = {}
	ancho_linea = 0.2
	RM = (baseModel*mtoi*0.5)-(ancho_linea*0.5)
	mX = 0
	mZ = 0
	pX = posX-self.getPosition().x
	pZ = posZ-self.getPosition().z

	M =  (mZ-pZ)/(mX-pX)
	M2 = -1/M
	--puntos ancla
	TA1 = 1 + (M2*M2)

	TA2 = -1*((2*(M2*M2)*pX)+(2*pX))

	TA3 = ((M2*M2)*(pX*pX))+(pX*pX)-(RM*RM)

	XA1 = (((-1)*(TA2)) + math.sqrt((TA2*TA2)-(4*TA1*TA3)))/(2*TA1) 
	XA2 = (((-1)*(TA2)) - math.sqrt((TA2*TA2)-(4*TA1*TA3)))/(2*TA1) 
	if XA1 < pX then F1 = -1 else F1 = 1 end
	if XA2 < pX then F2 = -1 else F2 = 1 end
	ZA1 = (math.sqrt((RM*RM)-(((XA1-pX)*(XA1-pX))))*F1)+pZ
	ZA2 = (math.sqrt((RM*RM)-(((XA2-pX)*(XA2-pX))))*F2)+pZ

	--puntos destino
	TB1 = 1 + (M2*M2)
	TB2 = -1*((2*(M2*M2)*mX)+(2*mX))
	TB3 = ((M2*M2)*(mX*mX))+(mX*mX)-(RM*RM)
	XB1 = (((-1)*(TB2)) + math.sqrt((TB2*TB2)-(4*TB1*TB3)))/(2*TB1) 
	XB2 = (((-1)*(TB2)) - math.sqrt((TB2*TB2)-(4*TB1*TB3)))/(2*TB1) 
	if XB1 < mX then F1 = -1 else F1 = 1 end
	if XB2 < mX then F2 = -1 else F2 = 1 end
	ZB1 = (math.sqrt((RM*RM)-(((XB1-mX)*(XB1-mX))))*F1)+mZ
	ZB2 = (math.sqrt((RM*RM)-(((XB2-mX)*(XB2-mX))))*F2)+mZ



	if M2 >=0 then
	sX=math.min(XA1,XA2)
	sZ=math.min(ZA1,ZA2)
	--print("("..sX..","..sZ..")")
	table.insert(result,{
            x = sX,
            z = sZ,
            y = 0.1 --posY+1
        })
	sX=math.min(XB1,XB2)
	sZ=math.min(ZB1,ZB2)
	--print("("..sX..","..sZ..")")
	table.insert(result,{
            x = sX,
            z = sZ,
            y = 0.1
        })
	sX=math.max(XB1,XB2)
	sZ=math.max(ZB1,ZB2)
	--print("("..sX..","..sZ..")")
	table.insert(result,{
            x = sX,
            z = sZ,
            y = 0.1 --posY+1
        })
	sX=math.max(XA1,XA2)
	sZ=math.max(ZA1,ZA2)
	--print("("..sX..","..sZ..")")
	table.insert(result,{
            x = sX,
            z = sZ,
            y = 0.1--posY+1
        })
	else
	sX=math.max(XA1,XA2)
	sZ=math.min(ZA1,ZA2)
	--print("("..sX..","..sZ..")")
	table.insert(result,{
            x = sX,
            z = sZ,
            y = 0.1 --posY+1
        })
	sX=math.max(XB1,XB2)
	sZ=math.min(ZB1,ZB2)
	--print("("..sX..","..sZ..")")
	table.insert(result,{
            x = sX,
            z = sZ,
            y = 0.1
        })
	sX=math.min(XB1,XB2)
	sZ=math.max(ZB1,ZB2)
	--print("("..sX..","..sZ..")")
	table.insert(result,{
            x = sX,
            z = sZ,
            y = 0.1 --posY+1
        })
	sX=math.min(XA1,XA2)
	sZ=math.max(ZA1,ZA2)
	--print("("..sX..","..sZ..")")
	table.insert(result,{
            x = sX,
            z = sZ,
            y = 0.1--posY+1
        })
	end


	table.insert(newLines,{
          points=result,
          color = colorLinea,
          thickness = ancho_linea,
          rotation = ({0, 0, 0})
        })
	self.setVectorLines(newLines)

end
function onNumberTyped( pc, n )

	if n > 0 and n <= 1 then
		rngMov=n
		txtMax = "\n(max "..n.."'')"
		colorLinea =Color(0.10,0.10,0.09)
		posicionLock()
	elseif  n > 0 and n <= 2 then
		rngMov=n
		txtMax = "\n(max "..n.."'')"
		colorLinea =Color(1,1,1)
		posicionLock()
	elseif  n > 0 and n <= 3 then
		rngMov=n
		txtMax = "\n(max "..n.."'')"
		colorLinea =Color(0,0.36,0.62)
		posicionLock()
	elseif  n > 0 and n <= 6 then
		rngMov=n
		txtMax = "\n(max "..n.."'')"
		colorLinea =Color(0.80,0.08,0.09)
		posicionLock()
	elseif n == 7 then
		
	elseif n == 8 then
		retira_Ruta()
	elseif n == 9 then
		agregaRuta()
	else
		objModel = getObjectFromGUID(GUIDModel)
--print(objModel)
		objModel.setPosition({x=self.getPosition().x,y=self.getPosition().y,z=self.getPosition().z},false)
		objModel.setVelocity({0,0,0})
        	objModel.setAngularVelocity({0,0,0})
		retira_Ruta_Chain()
	end
end

function onLoad(ls)
self.setName(
"Press 1-6 to change the distance\n" ..
"8 to cancel last step\n" ..
"9 to confirm step\n" ..
"0 to finish and move the model"
)
self.max_typed_number=9
rngMov=1
txtMax = "\n(max 1'')"
self.clearButtons()
local rango = {['function_owner'] = self, ['click_function'] = 'gg', ['label'] = "1''"..txtMax, ['position'] = {0, 0.25, 0}, ['rotation'] =  {0,0,0}, ['width'] = 5, ['height'] = 5, ['font_size'] = 150, ['font_color'] = {1,1,1}}
self.createButton(rango)
pickedUp = true
startLuaCoroutine(self, "movModel")	
pickedUp = false
end

function refrescaTextoRango()
cat1 = posX-self.getPosition().x
cat2 = posZ-self.getPosition().z
hip = math.sqrt((cat1*cat1)+(cat2*cat2))
if hip - math.floor(hip) > 0.005 then
hip=math.floor(hip)+1
else
hip=math.floor(hip)
end
self.editButton({index=0, label=hip.."''"..txtMax})
end

function agregaRuta()
CUBO = nill
DataObjeto = 
{
    type = "Custom_Model",
    scale = {1,1,1},
    rotation = {0, 0, 0},
    position = {85, 2, 100}
}
DataModel =
{
    mesh = "https://raw.githubusercontent.com/Ixidior/KTMT/main/"..baseModel.."MM.obj",
    diffuse = "https://raw.githubusercontent.com/xSpaghettyx/KT24-Table-The-Killzone-Mod/refs/heads/main/KTMT%20Diffuse.png",
    collider = "https://raw.githubusercontent.com/Ixidior/KTMT/main/collider4.obj",
    type = 0,
    material = 0,
    specular_intensity = 0,
	specular_sharpness = 7,
	freshnel_strength = 0.4
   
}
if CUBO == nill then

        CUBO = spawnObject(DataObjeto)
	--print(CUBO.getGUID())
        CUBO.setCustomObject(DataModel)
	CUBO.angular_drag = 0.1
	CUBO.bounciness = 0
	CUBO.dynamic_friction = 0.7
	CUBO.drag = 0.1
	CUBO.mass = 1
	CUBO.static_friction = 1

end
 WebRequest.get("https://raw.githubusercontent.com/xSpaghettyx/KT24-Table-The-Killzone-Mod/refs/heads/main/KTMT%20Movement.lua", function(req)
local script = req.text
CUBO.setLuaScript(script)
CUBO.setVar("GUIDModel",GUIDModel)
CUBO.setVar("GUIDNodPrev",self.getGUID())
end
)
self.setLock(true)
self.interactable = false 
end

function retira_Ruta()
obj = getObjectFromGUID(GUIDNodPrev)
obj.interactable = true
obj.setLock(false)
self.destruct()
end

function retira_Ruta_Chain()
if GUIDModel != GUIDNodPrev then 
obj = getObjectFromGUID(GUIDNodPrev)
obj.call("retira_Ruta_Chain")
self.destruct()
else
obj = getObjectFromGUID(GUIDNodPrev)
obj.setLock(false)
obj.interactable = true
self.destruct()
end
end
