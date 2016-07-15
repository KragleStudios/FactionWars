chatBox = {}

-- Dimensions
chatBox.Width = 525-- ChatBox dimensions
chatBox.Height = 235
chatBox.InputHeight = 25 -- Height of the text entry

-- Paddings
chatBox.HorizontalMargin = 5 -- Margin in pixels from the left of the screen
chatBox.VerticalMargin = 5 -- Margin in pixels from the bottom of the screen
chatBox.OuterMargin = 5 -- Margin applied to each element inside the chatbox in all directions
chatBox.InnerMargin = 0
-- Colors
chatBox.FrameColor = Color(0, 0, 0, 155) -- Color of the ChatBox frame
chatBox.InputColor = Color(0, 0, 0, 75) -- Color of the text entry
chatBox.OutlineColor = Color(0, 0, 0) -- Color of the outline for either
chatBox.TextColor = Color(255, 255, 255) -- Color of te text for the text entry
chatBox.CursorColor = Color(255, 255, 255) -- Color of the cursor for the text entry

--Misc
chatBox.FadeAwayTime = 5 -- Seconds before fading the chatbox after a new message arrives, or the chatbox is closed.

-- Internals. Don't edit these.
chatBox.Initialized = false
chatBox.Opened = false
chatBox.Teamed = false
chatBox.MaxMessageLength = 126
chatBox.Transparency = 0
chatBox.TargetTransparency = 0
chatBox.RichTextTransparency = 0
chatBox.RichTextTargetTransparency = 0
