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
colorLinea = Color(1,1,1)
state = nil
baseModel = nil
mtoi = 0.0393701
estado_cono = 0
targetConoX = nil 
targetConoY = nil
targetConoZ = nil
ObjMiniTarget = nil
objModel = nil


function onPickUp(cp)
clickPlayerColor = cp
--print(clickPlayerColor)
pickedUp = true
startLuaCoroutine(self, "movModel")


end

function movModel()
--print("entro")
--GUIDModel = "5c740c" --self.getDescription()
objModel = getObjectFromGUID(GUIDModel)
--print(objModel)
posX = objModel.getPosition().x
posZ = objModel.getPosition().z
posY = objModel.getPosition().y + 0.5
--print(posX)
--print(posZ)
state = objModel.getTable("state")
baseModel = objModel.getTable("state").base.x
--print(baseModel)

maxX = posX + rngMov
maxZ = posZ + rngMov
--print(posX.." | "..maxX.." | "..posZ.." | "..maxZ.." | "..rngMov)

while (pickedUp == true) do
posicionLock()
coroutine.yield(0)
end
return 1
end


function posicionLock()

		rngMov = baseModel*mtoi*0.5
	        mouseX = self.getPosition().x  
        	mouseZ = self.getPosition().z  
		newX = mouseX
		newZ = mouseZ
		FZ=1
		SX=0
		SZ=0
		--print("X:"..mouseX.."|Z:"..mouseZ)
		if math.sqrt(((mouseX-posX)*(mouseX-posX)) + ((mouseZ-posZ)*(mouseZ-posZ))) != rngMov then
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
				self.setPosition({x=newX, y=posY, z=newZ})
				self.setVelocity({0,0,0})
        			self.setAngularVelocity({0,0,0})
				--Wait.frames(function() print("corrigio") end, 5)
		else
			--print("fuera")
		end
		self.setRotation({0,0,0})
		refrescaVectores()
		

end

function onDropped(cp)
if pickedUp == true then
pickedUp = false
self.setPosition({x=newX, y=posY, z=newZ})
self.setVelocity({0,0,0})
self.setAngularVelocity({0,0,0})
self.setRotation({0,0,0})
--self.setDescription("X:"..newX.."|Z:"..newZ.."|Y:"..posY-posY)
refrescaVectores()
end
end	

function refrescaVectores()
lambda = 1
    if estado_cono == 2 then
	result = {}
	newLines = {}
	ancho_linea = 0.04
	
	baseModelT = ObjMiniTarget.getTable("state").base.x
	RM = ((baseModelT*mtoi*0.5)-(ancho_linea*0.5))*1
	RMO = ((baseModel*mtoi*0.5)-(ancho_linea*0.5))*0
	mX = 0--self.getPosition().x
	mZ = 0--self.getPosition().z
	--pX = posX-self.getPosition().x
	--pZ = posZ-self.getPosition().z
	pX = ObjMiniTarget.getPosition().x-self.getPosition().x
	pZ = ObjMiniTarget.getPosition().z-self.getPosition().z
	pY = ObjMiniTarget.getPosition().y-self.getPosition().y+0.05
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
	TB3 = ((M2*M2)*(mX*mX))+(mX*mX)-(RMO*RMO)
	XB1 = (((-1)*(TB2)) + math.sqrt((TB2*TB2)-(4*TB1*TB3)))/(2*TB1) 
	XB2 = (((-1)*(TB2)) - math.sqrt((TB2*TB2)-(4*TB1*TB3)))/(2*TB1) 
	if XB1 < mX then F1 = -1 else F1 = 1 end
	if XB2 < mX then F2 = -1 else F2 = 1 end
	ZB1 = (math.sqrt((RMO*RMO)-(((XB1-mX)*(XB1-mX))))*F1)+mZ
	ZB2 = (math.sqrt((RMO*RMO)-(((XB2-mX)*(XB2-mX))))*F2)+mZ



	if M2 >=0 then
	sX=math.min(XA1,XA2)
	sZ=math.min(ZA1,ZA2)
	--print("("..sX..","..sZ..")")
	Cx=sX-0
	Cz=sZ-0
	Cy=pY-(-0.45)
	mag1 = math.sqrt((Cx*Cx)+(Cy*Cy)+(Cz*Cz))
	Dx = Cx/mag1
	Dy = Cy/mag1
	Dz = Cz/mag1
	pfX = sX + (lambda*Dx)
	pfY = pY + (lambda*Dy)
	pfZ = sZ + (lambda*Dz)
	table.insert(result,{
            x = pfX,
            z = pfZ,
            y = pfY
        })
	sX=math.min(XB1,XB2)
	sZ=math.min(ZB1,ZB2)
	--print("("..sX..","..sZ..")")
	table.insert(result,{
            x = 0,
            z = 0,
            y = -0.45
        })

	sX=math.max(XA1,XA2)
	sZ=math.max(ZA1,ZA2)
	--print("("..sX..","..sZ..")")
	Cx=sX-0
	Cz=sZ-0
	Cy=pY-(-0.45)
	mag1 = math.sqrt((Cx*Cx)+(Cy*Cy)+(Cz*Cz))
	Dx = Cx/mag1
	Dy = Cy/mag1
	Dz = Cz/mag1
	pfX = sX + (lambda*Dx)
	pfY = pY + (lambda*Dy)
	pfZ = sZ + (lambda*Dz)
	table.insert(result,{
            x = pfX,
            z = pfZ,
            y = pfY
        })
	else
	sX=math.max(XA1,XA2)
	sZ=math.min(ZA1,ZA2)
	--print("("..sX..","..sZ..")")
	Cx=sX-0
	Cz=sZ-0
	Cy=pY-(-0.45)
	mag1 = math.sqrt((Cx*Cx)+(Cy*Cy)+(Cz*Cz))
	Dx = Cx/mag1
	Dy = Cy/mag1
	Dz = Cz/mag1
	pfX = sX + (lambda*Dx)
	pfY = pY + (lambda*Dy)
	pfZ = sZ + (lambda*Dz)
	table.insert(result,{
            x = pfX,
            z = pfZ,
            y = pfY
        })
	sX=math.max(XB1,XB2)
	sZ=math.min(ZB1,ZB2)
	--print("("..sX..","..sZ..")")
	table.insert(result,{
            x = 0,
            z = 0,
            y = -0.45
        })

	sX=math.min(XA1,XA2)
	sZ=math.max(ZA1,ZA2)
	--print("("..sX..","..sZ..")")
	Cx=sX-0
	Cz=sZ-0
	Cy=pY-(-0.45)
	mag1 = math.sqrt((Cx*Cx)+(Cy*Cy)+(Cz*Cz))
	Dx = Cx/mag1
	Dy = Cy/mag1
	Dz = Cz/mag1
	pfX = sX + (lambda*Dx)
	pfY = pY + (lambda*Dy)
	pfZ = sZ + (lambda*Dz)
	table.insert(result,{
            x = pfX,
            z = pfZ,
            y = pfY
        })
	end


	table.insert(newLines,{
          points=result,
          color = colorLinea,
          thickness = ancho_linea,
          rotation = ({0, 0, 0})
        })
	self.setVectorLines(newLines)
	refrescaTextoRango()
 	--print("posY"..posY)
	--print("self"..self.getPosition().y)
	--print("total"..posY-self.getPosition().y)
     end
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
		
	elseif n == 9 then
		
	else
		objModel = getObjectFromGUID(GUIDModel)
		--print(objModel)

		self.destruct()
	end
end

function onLoad(ls)
self.setName(
"Hover over the cone and press R to select the target\n" ..
"Press 1-4 to change the line color\n" ..
"0 to finish\n" ..
)
self.max_typed_number=9
rngMov=3
txtMax = "\n(max 1'')"
self.clearButtons()
local rango = {['function_owner'] = self, ['click_function'] = 'gg', ['label'] = "0''", ['position'] = {0, 0.5, 0}, ['rotation'] =  {0,0,0}, ['width'] = 5, ['height'] = 5, ['font_size'] = 150, ['font_color'] = {1,1,1}}
self.createButton(rango)
pickedUp = true
startLuaCoroutine(self, "movModel")	
pickedUp = false
self.setVectorLines(nil)
end



function refrescaTextoRango()
cat1 = objModel.getPosition().x-ObjMiniTarget.getPosition().x
--print(cat1)
cat2 = objModel.getPosition().z-ObjMiniTarget.getPosition().z
--print(cat2)
cat3 = objModel.getPosition().y-objModel.getBounds().offset.y-ObjMiniTarget.getPosition().y-ObjMiniTarget.getBounds().offset.y
--print(cat3)
lhip = math.sqrt((cat1*cat1)+(cat2*cat2))-((objModel.getTable("state").base.x+ObjMiniTarget.getTable("state").base.x)*mtoi*0.5)
--print(lhip)
hip = math.sqrt((lhip*lhip)+(cat3*cat3))
hip=math.ceil(hip)
self.editButton({index=0, label=hip.."''"})
end

function tryRandomize(pc)
  estado_cono = 1
  --print("seleccione objetivo")
 msg = "Select Target for LOS"
color = pc
rgb = {r=1, g=1, b=1}
broadcastToColor(msg, color, rgb)
  return false
end

function onObjectPickUp(selfpc, targetObj)
  if estado_cono == 1 then
    --print(targetObj.getGUID())
    --print(targetObj.getPosition())
    ObjMiniTarget = targetObj
    targetConoX = targetObj.getPosition().x
    targetConoY = targetObj.getPosition().y
    targetConoZ = targetObj.getPosition().z
    estado_cono = 2
    refrescaVectores()
  end
end
