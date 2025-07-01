classdef myFFT_App_app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        figure1      matlab.ui.Figure
        GridLayout   matlab.ui.container.GridLayout
        pushbutton3  matlab.ui.control.Button
        pushbutton2  matlab.ui.control.Button
        popupmenu1   matlab.ui.control.DropDown
        text4        matlab.ui.control.Label
        text3        matlab.ui.control.Label
        text2        matlab.ui.control.Label
        pushbutton1  matlab.ui.control.Button
        axes2        matlab.ui.control.UIAxes
        axes1        matlab.ui.control.UIAxes
    end


    methods (Access = private)
        function edit_angle_CreateFcn(app, hObject, eventdata, handles)
            % --- Executes during object creation, after setting all properties.
            
            % hObject    handle to edit_angle (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    empty - handles not created until after all CreateFcns called
            
            % Hint: edit controls usually have a white background on Windows.
            %       See ISPC and COMPUTER.
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end
        end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function untitled_OpeningFcn(app, varargin)
            % --- Executes just before untitled is made visible.
            
            % Ensure that the app appears on screen when run
            movegui(app.figure1, 'onscreen');
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app); %#ok<ASGLU>
            
            % This function has no output args, see OutputFcn.
            % hObject    handle to figure
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            % varargin   command line arguments to untitled (see VARARGIN)
            
            % Choose default command line output for untitled
            handles.output = hObject;
            
            % Update handles structure
            guidata(hObject, handles);
            global img;
            img = [];
        end

        % Value changed function: popupmenu1
        function popupmenu1_Callback(app, event)
            % --- Executes on selection change in popupmenu1.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
                contents = cellstr(get(hObject,'String'));
                selected = contents{get(hObject,'Value')};
                %cla(handles.axes2);  % 清空 axes2
            
                if strcmp(selected, '旋转') || strcmp(selected, '缩放') || strcmp(selected, '位移')
                    set(handles.pushbutton2, 'Visible', 'on');
                else
                    set(handles.pushbutton2, 'Visible', 'off');
                end
        end

        % Button pushed function: pushbutton1
        function pushbutton1_Callback(app, event)
            % --- Executes on button press in pushbutton1.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to pushbutton1 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            global img;
            global img currentImg;

            cla(handles.axes1);  % 清空 axes1
            cla(handles.axes2);  % 清空 axes2
            
            [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp'}, '选择图像');
            if isequal(filename,0)
                return;
            end
            img = imread(fullfile(pathname, filename));
            currentImg = [];  % 重置连续操作状态
            axes(handles.axes1);
            imshow(img);
        end

        % Button pushed function: pushbutton2
        function pushbutton2_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            global img currentImg;  % 添加currentImg用于连续操作
            
            % 检查是否导入图像
            if isempty(img)
                msgbox('请先导入图像', '提示', 'warn');
                return;
            end
            
            % 清空显示区域
            cla(handles.axes2);
            title(handles.axes2, '');
            
            contents = cellstr(get(handles.popupmenu1,'String'));
            selected = contents{get(handles.popupmenu1,'Value')};
            
            % 判断使用原始图像还是当前处理后的图像
            if isempty(currentImg)
                % 第一次处理，使用原始图像
                processImg = im2gray(img);
            else
                % 连续操作，使用上次处理结果
                if size(currentImg, 3) == 3
                    processImg = im2gray(currentImg);
                else
                    processImg = currentImg;
                end
            end
            
            % 执行图像处理
            if strcmp(selected, '旋转')
                % 旋转45°
                rotated = imrotate(processImg, 45, 'bilinear', 'crop');
                currentImg = rotated;  % 保存当前状态
                F = fftshift(fft2(rotated));
                spectrum = log(abs(F) + 1);
                axes(handles.axes2);
                imshow(spectrum, []);
                title('频谱：旋转45度后');
                
            elseif strcmp(selected, '位移')
                % 平移+50像素(x方向)
                shifted = imtranslate(processImg, [50, 0]);
                currentImg = shifted;  % 保存当前状态
                F = fftshift(fft2(shifted));
                spectrum = log(abs(F) + 1);
                axes(handles.axes2);
                imshow(spectrum, []);
                title('频谱：平移50像素后');
                
            elseif strcmp(selected, '缩放')
                % 缩放0.8倍
                scale = 0.8;
                scaled = imresize(processImg, scale);
                
                % 居中填充
                [H, W] = size(processImg);
                canvas = zeros(H, W);
                [h2, w2] = size(scaled);
                row_start = floor((H - h2)/2) + 1;
                col_start = floor((W - w2)/2) + 1;
                canvas(row_start:row_start+h2-1, col_start:col_start+w2-1) = scaled;
                
                currentImg = canvas;  % 保存当前状态
                F = fftshift(fft2(canvas));
                spectrum = log(abs(F) + 1);
                axes(handles.axes2);
                imshow(spectrum, []);
                title('频谱：缩放0.8倍后');
                
            else
                msgbox('请选择有效的图像处理方式', '提示', 'warn');
            end
        end

        % Button pushed function: pushbutton3
        function pushbutton3_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            global img currentImg;
            
            % 检查是否已加载图像
            if isempty(img)
                msgbox('没有可重置的图像', '提示', 'warn');
                return;
            end
            
            % 重置状态
            currentImg = [];
            
            % 重新显示原始图像
            axes(handles.axes1);
            imshow(img);
            
            % 清空频谱显示
            cla(handles.axes2);
            title(handles.axes2, '');
            
            % 可选：弹出提示信息
            msgbox('已重置到原始图像状态', '提示', 'help');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create figure1 and hide until all components are created
            app.figure1 = uifigure('Visible', 'off');
            app.figure1.Position = [1268 1185 1110 647];
            app.figure1.Name = '傅里叶变换性质';
            app.figure1.Resize = 'off';
            app.figure1.Theme = 'light';
            app.figure1.HandleVisibility = 'callback';
            app.figure1.Tag = 'figure1';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.figure1);
            app.GridLayout.ColumnWidth = {177, '2.54x', 193, '1x', '1.5x', 277};
            app.GridLayout.RowHeight = {32, 32, 34, 30, 26, '4.43x', 33, '1x', 34, '2.45x'};
            app.GridLayout.ColumnSpacing = 3.42855507986886;
            app.GridLayout.RowSpacing = 3.05454496903853;
            app.GridLayout.Padding = [3.42855507986886 3.05454496903853 3.42855507986886 3.05454496903853];

            % Create axes1
            app.axes1 = uiaxes(app.GridLayout);
            app.axes1.FontSize = 13.3333333333333;
            app.axes1.NextPlot = 'replace';
            app.axes1.Layout.Row = [3 10];
            app.axes1.Layout.Column = [2 4];
            app.axes1.Tag = 'axes1';
            app.axes1.Visible = 'off';

            % Create axes2
            app.axes2 = uiaxes(app.GridLayout);
            app.axes2.FontSize = 13.3333333333333;
            app.axes2.NextPlot = 'replace';
            app.axes2.Layout.Row = [3 10];
            app.axes2.Layout.Column = [5 6];
            app.axes2.Tag = 'axes2';
            app.axes2.Visible = 'off';

            % Create pushbutton1
            app.pushbutton1 = uibutton(app.GridLayout, 'push');
            app.pushbutton1.ButtonPushedFcn = createCallbackFcn(app, @pushbutton1_Callback, true);
            app.pushbutton1.Tag = 'pushbutton1';
            app.pushbutton1.FontSize = 16;
            app.pushbutton1.Layout.Row = 3;
            app.pushbutton1.Layout.Column = 1;
            app.pushbutton1.Interpreter = 'latex';
            app.pushbutton1.Text = '导入图片';

            % Create text2
            app.text2 = uilabel(app.GridLayout);
            app.text2.Tag = 'text2';
            app.text2.HorizontalAlignment = 'center';
            app.text2.VerticalAlignment = 'top';
            app.text2.WordWrap = 'on';
            app.text2.FontSize = 24;
            app.text2.Layout.Row = 2;
            app.text2.Layout.Column = 3;
            app.text2.Interpreter = 'latex';
            app.text2.Text = '原始图像';

            % Create text3
            app.text3 = uilabel(app.GridLayout);
            app.text3.Tag = 'text3';
            app.text3.HorizontalAlignment = 'center';
            app.text3.VerticalAlignment = 'top';
            app.text3.WordWrap = 'on';
            app.text3.FontName = 'JetBrains Mono ExtraBold';
            app.text3.FontSize = 24;
            app.text3.Layout.Row = 2;
            app.text3.Layout.Column = [5 6];
            app.text3.Interpreter = 'latex';
            app.text3.Text = '处理后图像';

            % Create text4
            app.text4 = uilabel(app.GridLayout);
            app.text4.Tag = 'text4';
            app.text4.BackgroundColor = [0.94 0.94 0.94];
            app.text4.HorizontalAlignment = 'center';
            app.text4.VerticalAlignment = 'top';
            app.text4.WordWrap = 'on';
            app.text4.FontSize = 16;
            app.text4.FontColor = [0 0 0];
            app.text4.Layout.Row = 4;
            app.text4.Layout.Column = 1;
            app.text4.Interpreter = 'latex';
            app.text4.Text = '选择处理模式';

            % Create popupmenu1
            app.popupmenu1 = uidropdown(app.GridLayout);
            app.popupmenu1.Items = {'旋转', '位移', '缩放'};
            app.popupmenu1.ValueChangedFcn = createCallbackFcn(app, @popupmenu1_Callback, true);
            app.popupmenu1.Tag = 'popupmenu1';
            app.popupmenu1.FontSize = 16;
            app.popupmenu1.FontColor = [0 0 0];
            app.popupmenu1.BackgroundColor = [1 1 1];
            app.popupmenu1.Layout.Row = 5;
            app.popupmenu1.Layout.Column = 1;
            app.popupmenu1.Value = '旋转';

            % Create pushbutton2
            app.pushbutton2 = uibutton(app.GridLayout, 'push');
            app.pushbutton2.ButtonPushedFcn = createCallbackFcn(app, @pushbutton2_Callback, true);
            app.pushbutton2.Tag = 'pushbutton2';
            app.pushbutton2.FontSize = 16;
            app.pushbutton2.Layout.Row = 9;
            app.pushbutton2.Layout.Column = 1;
            app.pushbutton2.Interpreter = 'latex';
            app.pushbutton2.Text = '处理图片';

            % Create pushbutton3
            app.pushbutton3 = uibutton(app.GridLayout, 'push');
            app.pushbutton3.ButtonPushedFcn = createCallbackFcn(app, @pushbutton3_Callback, true);
            app.pushbutton3.Tag = 'pushbutton3';
            app.pushbutton3.FontSize = 16;
            app.pushbutton3.Layout.Row = 7;
            app.pushbutton3.Layout.Column = 1;
            app.pushbutton3.Interpreter = 'latex';
            app.pushbutton3.Text = '重置';

            % Show the figure after all components are created
            app.figure1.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = myFFT_App_app_exported(varargin)

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.figure1)

                % Execute the startup function
                runStartupFcn(app, @(app)untitled_OpeningFcn(app, varargin{:}))
            else

                % Focus the running singleton app
                figure(runningApp.figure1)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.figure1)
        end
    end
end