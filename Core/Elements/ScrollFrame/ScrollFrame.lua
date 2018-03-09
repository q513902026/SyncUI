
function SyncUI_ScrollFrame_OnLoad(self)
	local scrollBar = self.ScrollBar
	local thumb = scrollBar.Thumb
	
	scrollBar:SetMinMaxValues(0, 0)
	scrollBar:SetValue(0)
	self.offset = 0
	
	scrollBar:Hide()
end

function SyncUI_ScrollFrame_OnScrollRangeChanged(self, xRange, yRange)
	local frame = self:GetParent()
	local scrollBar = self.ScrollBar
	local thumb = scrollBar.Thumb
	local value = scrollBar:GetValue()
	
	if not yRange then
		yRange = self:GetVerticalScrollRange()
	end

	-- Bag Scroll Fix!
	if frame == SyncUI_BagFrame or frame == SyncUI_BankFrame.Normal then
		yRange = tonumber(string.format("%.0f", yRange-26.5))
	end
	
	if yRange < 0 then
		yRange = 0
	end

	if value > yRange then
		value = yRange
	end
	
	scrollBar:SetMinMaxValues(0, yRange)
	scrollBar:SetValue(value)

	if floor(yRange) == 0 then
		scrollBar:Hide()
	else
		scrollBar:Show()
	end
end

function SyncUI_ScrollFrame_OnMouseWheel(self, value)
	local scrollBar = self.ScrollBar
	local scrollStep = scrollBar.scrollStep or scrollBar:GetHeight() / 4
	
	if value > 0 then
		scrollBar:SetValue(scrollBar:GetValue() - scrollStep)
	else
		scrollBar:SetValue(scrollBar:GetValue() + scrollStep)
	end
end

function SyncUI_ScrollFrame_OnVerticalScroll(self, value, itemHeight, updateFunction)
	local scrollBar = self.ScrollBar
	
	scrollBar:SetValue(value)
	self.offset = floor((value / itemHeight) + 0.5)
	
	if updateFunction then
		updateFunction(self)
	end
end

function SyncUI_ScrollFrame_Update(frame, numItems, numToDisplay, buttonHeight, button, smallWidth, bigWidth, highlightFrame, smallHighlightWidth, bigHighlightWidth, alwaysShowScrollBar)
	local scrollBar = frame.ScrollBar
	local showScrollBar

	if numItems > numToDisplay or alwaysShowScrollBar then
		frame:Show()
		showScrollBar = 1
	else
		scrollBar:SetValue(0)
		frame:Hide()
	end
	
	if frame:IsShown() then
		local childFrame = frame.ChildFrame
		local scrollFrameHeight, scrollChildHeight = 0, 0
		
		if numItems > 0 then
			scrollFrameHeight = (numItems - numToDisplay) * buttonHeight;
			scrollChildHeight = numItems * buttonHeight
			
			if scrollFrameHeight < 0 then
				scrollFrameHeight = 0
			end
			
			childFrame:Show()
		else
			childFrame:Hide()
		end
		
		local maxRange = (numItems - numToDisplay) * buttonHeight
		
		if maxRange < 0 then
			maxRange = 0
		end
		
		scrollBar:SetMinMaxValues(0, maxRange)
		scrollBar:SetValueStep(buttonHeight)
		scrollBar:SetStepsPerPage(numToDisplay-1)
		childFrame:SetHeight(scrollChildHeight)

		-- Shrink because scrollbar is shown
		if highlightFrame then
			highlightFrame:SetWidth(smallHighlightWidth)
		end
		if button then
			for i = 1, numToDisplay do
				_G[button..i]:SetWidth(smallWidth)
			end
		end

	end
	
	if not frame:IsShown() then
		-- Widen because scrollbar is hidden
		if highlightFrame then
			highlightFrame:SetWidth(bigHighlightWidth)
		end
		if button then
			for i = 1, numToDisplay do
				_G[button..i]:SetWidth(bigWidth)
			end
		end
	end

	return showScrollBar
end