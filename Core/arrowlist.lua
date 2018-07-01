function dgsCreateArrowList(x,y,sx,sy,relative,parent,itemHeight,itemTextColor,scalex,scaley,defcolor,hovcolor,idefcolor,ihovcolor,defimage,hovimage,idefimage,ihovimage)
	assert(tonumber(x),"Bad argument @dgsCreateArrowList at argument 1, expect number got "..type(x))
	assert(tonumber(y),"Bad argument @dgsCreateArrowList at argument 2, expect number got "..type(y))
	assert(tonumber(sx),"Bad argument @dgsCreateArrowList at argument 3, expect number got "..type(sx))
	assert(tonumber(sy),"Bad argument @dgsCreateArrowList at argument 4, expect number got "..type(sy))
	if isElement(parent) then
		assert(dgsIsDxElement(parent),"Bad argument @dgsCreateGridList at argument 6, expect dgs-dxgui got "..dgsGetType(parent))
	end
	local arrowlist = createElement("dgs-dxarrowlist")
	dgsSetType(arrowlist,"dgs-dxarrowlist")
	local _x = dgsIsDxElement(parent) and dgsSetParent(arrowlist,parent,true) or table.insert(CenterFatherTable,1,arrowlist)
	dgsSetData(arrowlist,"mode",false)
	dgsSetData(arrowlist,"bgcolor",tocolor(255,255,255,200))
	dgsSetData(arrowlist,"bgimage",nil)
	dgsSetData(arrowlist,"scrollBarThick",20,true)
	dgsSetData(arrowlist,"itemData",{})
	dgsSetData(arrowlist,"leading",10)
	dgsSetData(arrowlist,"itemHeight",itemHeight or 20)
	dgsSetData(arrowlist,"itemMoveOffset",0)
	dgsSetData(arrowlist,"itemTextShadow",nil)
	dgsSetData(arrowlist,"itemImage",nil)
	dgsSetData(arrowlist,"font",systemFont)
	dgsSetData(arrowlist,"itemTextColor",itemTextColor or tocolor(0,0,0,255))
	dgsSetData(arrowlist,"itemTextSize",{tonumber(scalex) or 1,tonumber(scaley) or 1})
	dgsSetData(arrowlist,"itemTextOffset",2)
	dgsSetData(arrowlist,"itemTextAlignment","left")
	dgsSetData(arrowlist,"selectorAlignment","right")
	dgsSetData(arrowlist,"selectorWidth",nil)	--Auto Config [Text Width]
	dgsSetData(arrowlist,"selectorDistance",5)	-- <(Distance)Text(Distance)>
	dgsSetData(arrowlist,"selectorOffset",5)
	dgsSetData(arrowlist,"selectorShadow",nil)
	dgsSetData(arrowlist,"selectorSize",{1,1})
	dgsSetData(arrowlist,"selectorTextColor",tocolor(0,0,0,255))
	dgsSetData(arrowlist,"selectorColor",{tocolor(0,0,0,255),tocolor(200,200,200,255),tocolor(100,100,100,255)})
	dgsSetData(arrowlist,"itemColor",{idefcolor or schemeColor.arrowlist.itemColor[1],ihovcolor or schemeColor.arrowlist.itemColor[2]})
	dgsSetData(arrowlist,"itemImage",{idefimage,ihovimage})
	insertResourceDxGUI(sourceResource,arrowlist)
	calculateGuiPositionSize(arrowlist,x,y,relative,sx,sy,relative,true)
	local aSize = dgsElementData[arrowlist].absSize
	local abx,aby = aSize[1],aSize[2]
	local rndtgt = dxCreateRenderTarget(abx,aby,true)
	local scrollbar = dgsCreateScrollBar(abx-20,0,20,aby,false,false,arrowlist)
	dgsSetData(arrowlist,"renderTarget",rndtgt)
	dgsSetData(scrollbar,"length",{0,true})
	dgsSetData(arrowlist,"scrollbar",scrollbar)
	dgsSetVisible(scrollbar,false)
	triggerEvent("onDgsCreate",arrowlist)
	return arrowlist
end

--[[
Item Data Structure:
itemData = {
	 1	  2           3         4    5              6               7
	{text,range start,range end,step,translateTable,currentSelected,configTable},
	{text,range start,range end,step,translateTable,currentSelected,configTable},
	{text,range start,range end,step,translateTable,currentSelected,configTable},
	{text,range start,range end,step,translateTable,currentSelected,configTable},
	...
}

translateTable = {
	[1] = text1,
	[2] = text2,
	[3] = text3,
	...
}


]]
function dgsArrowListAddItem(arrowlist,text,rangeStart,rangeEnd,step,translationTable,pos)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListAddItem at argument 1, expect number got "..dgsGetType(arrowlist))
	assert(type(text) == "string","Bad argument @dgsArrowListAddItem at argument 2, expect string got "..dgsGetType(text))
	assert(tonumber(rangeStart),"Bad argument @dgsArrowListAddItem at argument 3, expect number got "..type(rangeStart))
	assert(tonumber(rangeEnd),"Bad argument @dgsArrowListAddItem at argument 4, expect number got "..type(rangeEnd))
	step = tonumber(step) or 1
	assert(step > 0,"Bad argument @dgsArrowListAddItem at argument 5, expect number got "..type(rangeEnd))
	local eleData = dgsElementData[arrowlist]
	local itemData = eleData.itemData
	local itemCount = #itemData+1
	-------------Config Table
	local configTable = {
		[1] = eleData.itemColor,
		[2] = eleData.itemImage,
		[3] = eleData.itemTextColor,
		[4] = eleData.itemTextSize,
		[5] = eleData.font,		--item text font
		[6] = eleData.itemTextAlignment,
		[7] = eleData.itemTextOffset,
		[8] = eleData.itemTextShadow, -- include < and >
		
		[9] = eleData.selectorColor,	-- < and > only
		[10] = eleData.selectorSize,	-- exclude < and >
		[11] = eleData.font,		--selector font ( exclude < and > )
		[12] = eleData.selectorAlignment,  -- include < and >
		[13] = eleData.selectorOffset,  -- include < and >
		[14] = eleData.selectorWidth,
		[15] = eleData.selectorShadow, -- exclude < and > 
		[16] = eleData.selectorDistance,
		[17] = eleData.selectorTextColor,
	}
	-------------
	local tab = {}
	local size = eleData.absSize
	tab = {
		[1] = text,
		[2] = rangeStart,
		[3] = rangeEnd,
		[4] = step,
		[5] = translationTable,
		[6] = rangeStart,	--Current Selected
		[7] = configTable
	}
	table.insert(itemData,pos or itemCount,tab)
	local itemHeight = dgsElementData[arrowlist].itemHeight
	local leading = dgsElementData[arrowlist].leading
	local scrollBarVisible = itemCount*itemHeight+(itemCount-1)*leading > size[2]
	local scrollBar = dgsElementData[arrowlist].scrollbar
	dgsSetVisible(scrollBar,scrollBarVisible)
	local sbt = scrollBarVisible and dgsElementData[arrowlist].scrollBarThick or 0
	local rendertarget = dgsElementData[arrowlist].renderTarget
	if isElement(rendertarget) then
		destroyElement(rendertarget)
	end
	local rendertarget = dxCreateRenderTarget(size[1]-sbt,size[2],true)
	dgsSetData(arrowlist,"renderTarget",rendertarget)
	return pos or itemCount
end

function dgsArrowListRemoveItem(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListRemoveItem at argument 1, expect number got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListRemoveItem at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		table.remove(itemData,index)
		return true
	end
	return false
end

function dgsArrowListSetItemText(arrowlist,index,text)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListSetItemText at argument 1, expect number got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListSetItemText at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		itemData[index][1] = text
		return true
	end
	return false
end

function dgsArrowListGetItemText(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListGetItemText at argument 1, expect number got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListGetItemText at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		return itemData[index][1]
	end
	return false
end

function dgsArrowListGetItemValue(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListGetItemValue at argument 1, expect number got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListGetItemValue at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		return itemData[index][6]
	end
	return false
end

function dgsArrowListSetItemValue(arrowlist,index,value)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListSetItemValue at argument 1, expect number got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListSetItemValue at argument 2, expect number got "..type(index))
	assert(tonumber(value),"Bad argument @dgsArrowListSetItemValue at argument 3, expect number got "..type(value))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		itemData[index][6] = value
	end
	return false
end

function dgsArrowListGetItemRange(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListGetItemRange at argument 1, expect number got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListGetItemRange at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		return itemData[index][2],itemData[index][3]
	end
	return false
end

function dgsArrowListSetItemRange(arrowlist,index,rangeStart,rangeEnd)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListSetItemRange at argument 1, expect number got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListSetItemRange at argument 2, expect number got "..type(index))
	assert(tonumber(rangeStart),"Bad argument @dgsArrowListSetItemRange at argument 3, expect number got "..type(rangeStart))
	assert(tonumber(rangeEnd),"Bad argument @dgsArrowListSetItemRange at argument 4, expect number got "..type(rangeEnd))
	assert(rangeStart <= rangeEnd,"Bad argument @dgsArrowListSetItemRange at argument 3 and 4, range start should be less than or equal to range end, got rangeStart:"..rangeStart..",rangeEnd:"..rangeEnd)
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		itemData[index][2] = rangeStart
		itemData[index][3] = rangeEnd
		return true
	end
	return false
end

function dgsArrowListGetItemTranslationTable(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListGetItemTranslationTable at argument 1, expect number got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListGetItemTranslationTable at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		return itemData[index][5]
	end
	return false
end

function dgsArrowListSetItemTranslationTable(arrowlist,index,translationTable)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListSetItemTranslationTable at argument 1, expect number got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListSetItemTranslationTable at argument 2, expect number got "..type(index))
	assert(type(translationTable) == "table","Bad argument @dgsArrowListSetItemTranslationTable at argument 3, expect table got "..type(translationTable))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		itemData[index][5] = translationTable
		return true
	end
	return false
end

function dgsArrowListSetItemStep(arrowlist,index,step)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListSetItemStep at argument 1, expect number got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListSetItemStep at argument 2, expect number got "..type(index))
	assert(tonumber(step),"Bad argument @dgsArrowListSetItemStep at argument 3, expect number got "..type(step))
	assert(step >= 0,"Bad argument @dgsArrowListSetItemStep at argument 3, step should be greater than or equal to 0, got "..step)
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		itemData[index][4] = step
	end
	return false
end

function dgsArrowListGetItemStep(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListGetItemStep at argument 1, expect number got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListGetItemStep at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		return itemData[index][4]
	end
	return false
end

function dgsArrowListGetItemTranslatedValue(arrowlist,index)
	assert(dgsGetType(arrowlist) == "dgs-dxarrowlist","Bad argument @dgsArrowListGetItemTranslatedValue at argument 1, expect number got "..dgsGetType(arrowlist))
	assert(tonumber(index),"Bad argument @dgsArrowListGetItemTranslatedValue at argument 2, expect number got "..type(index))
	local itemData = dgsElementData[arrowlist].itemData
	if itemData and itemData[index] then
		local translationTable = itemData[index][5]
		return translationTable[ itemData[index][6] ] or itemData[index][6]
	end
	return false
end

addEventHandler("onDgsScrollBarScrollPositionChange",root,function(new,old)
	local parent = dgsGetParent(source)
	if dgsGetType(parent) == "dgs-dxarrowlist" then
		local scrollBar = dgsElementData[parent].scrollbar
		local sx,sy = dgsElementData[parent].absSize[1],dgsElementData[parent].absSize[2]
		if source == scrollBar then
			local itemCount = #dgsElementData[parent].itemData
			local itemLength = itemCount*dgsElementData[parent].itemHeight+(itemCount-1)*dgsElementData[parent].leading
			local temp = -new*(itemLength-sy)/100
			local temp = dgsElementData[parent].scrollFloor and math.floor(temp) or temp 
			dgsSetData(parent,"itemMoveOffset",temp)
		end
	end
end)

function configArrowList(arrowlist)
	local size = dgsElementData[arrowlist].absSize
	local itemHeight = dgsElementData[arrowlist].itemHeight
	local leading = dgsElementData[arrowlist].leading
	local scrollBar = dgsElementData[arrowlist].scrollbar
	local itemCount = #dgsElementData[arrowlist].itemData
	local scrollBarVisible = itemCount*itemHeight+(itemCount-1)*leading > size[2]
	dgsSetVisible(scrollBar,scrollBarVisible)
	local sbt = scrollBarVisible and dgsElementData[arrowlist].scrollBarThick or 0
	local rendertarget = dgsElementData[arrowlist].renderTarget
	if isElement(rendertarget) then
		destroyElement(rendertarget)
	end
	local rendertarget = dxCreateRenderTarget(size[1]-sbt,size[2],true)
	dgsSetData(arrowlist,"renderTarget",rendertarget)
	dgsSetPosition(scrollBar,size[1]-dgsElementData[arrowlist].scrollBarThick,0,false)
	dgsSetSize(scrollBar,sbt,size[2],false)
end