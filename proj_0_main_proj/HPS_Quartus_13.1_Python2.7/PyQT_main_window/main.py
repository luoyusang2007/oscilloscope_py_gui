#/usr/bin/python
"""
===========================
    Author: Luo Yusang
    Nanchang University
    Sept. 2016
===========================
"""
import subprocess
import soc_gui
from PyQt4 import QtCore, QtGui
import math

class Wave(QtGui.QGraphicsItem):
    pen = QtGui.QPen()
    def __init__(self,scene):
        super(Wave,self).__init__()
        self.pen.setWidth(2)
        self.pen.setCapStyle(QtCore.Qt.RoundCap)
        self.pen.setJoinStyle(QtCore.Qt.RoundJoin)
        

    def boundingRect(self):
        return QtCore.QRectF(Disp_Hor_L,Disp_Ver_T,Disp_Horizontal_Span,Disp_Vertical_Span)
    def paint(self,painter,option,widget):
        #Following: New path object
        wave_path = QtGui.QPainterPath()

        self.pen.setColor(QtGui.QColor(255,0,0,ui.spinBox_draw_brightness.value()))
        painter.setPen(self.pen)

        #Following: Now Paint
        start_H = int((0-Data_Length/2) / Disp_H_Shrink_Coef)
        wave_path.moveTo(start_H,Data_Arr[0])
        for i in range(Data_Length):
            paint_H = int((i-Data_Length/2) / Disp_H_Shrink_Coef)
            wave_path.lineTo(paint_H,Data_Arr[i])
        painter.drawPath(wave_path)

        #Following: Delete path object
        del wave_path


def paint_grid():
    line_pen = QtGui.QPen()
    line_pen.setColor(QtCore.Qt.gray)
    line_pen.setStyle(QtCore.Qt.DotLine)

    for i in range(Disp_Hor_L , Disp_Hor_R+1 , 50):
        ui.scene.addLine(i,Disp_Ver_T,i,Disp_Ver_B,line_pen)
    for i in range(Disp_Ver_T , Disp_Ver_B+1, 50):
        ui.scene.addLine(Disp_Hor_L,i,Disp_Hor_R,i,line_pen)
    
    line_pen.setStyle(QtCore.Qt.SolidLine)
    for i in range(Disp_Hor_L , Disp_Hor_R+1 , 10):
        ui.scene.addLine(i,3,i,-3,line_pen)
        
    for i in range(Disp_Ver_T , Disp_Ver_B+1, 10):
        ui.scene.addLine(-3,i,3,i,line_pen)
        
#    ui.scene.addLine(-512,0,512,0,line_pen)
#    ui.scene.addLine(0,200,0,-200,line_pen)

def paint_wave():

    if(ui.comboBox_couple_mode.currentText() == 'DC'):
        couple_mode = 1
    else:
        couple_mode = 0

    gain_value = ui.spinBox_ch1_vertical.value()
    if(gain_value <= 256):
        gain_relay = 1
    else:
        gain_relay = 0
        gain_value = gain_value - 256
        
    trigger_level = ui.spinBox_trigger_level.value()
    
    set_string = "s %-1d %-1d %-5d %-5d\n" % (couple_mode, gain_relay, gain_value, trigger_level)
    print set_string,
    sp.stdin.write(set_string)
    sp.stdin.flush()
    
    for i in range(Data_Length):
        message = sp.stdout.readline()
        Data_Arr[i] = (int(message) - 127) * Disp_V_Expand_Coef
    wave_item.update()
    ui.scene.update()
    ui.graphicsView_wave.update()
    
 

if __name__ == "__main__":
    import sys

    #Parameters Defination
    Data_Length = 1024
    
    Disp_Vertical_Span = 500
    Disp_Horizontal_Span = 1100

    #Parameters initialization
    Data_Arr = range(Data_Length)

    Disp_Ver_T = -int(Disp_Vertical_Span/2)
    Disp_Ver_B = int(Disp_Vertical_Span/2)

    Disp_Hor_L = -int(Disp_Horizontal_Span/2)
    Disp_Hor_R = int(Disp_Horizontal_Span/2)
    

    #Data Options
    #Following coefficients will not influence display scene area
    #But will influence waveform display area
    Disp_V_Expand_Coef = 2
    Disp_H_Shrink_Coef = 2

    #Following: Open subprocess
    sp = subprocess.Popen("./C_subprocess/osc_subprocess",stdin = subprocess.PIPE, stdout = subprocess.PIPE, stderr = subprocess.PIPE)

    app = QtGui.QApplication(sys.argv)
    MainWindow = QtGui.QMainWindow()
    ui = soc_gui.Ui_MainWindow()
    ui.setupUi(MainWindow)

    #Following: Full screen
    MainWindow.showFullScreen()

    #Following: Set view size mode when changing window size
    ui.splitter.setStretchFactor(1,1)

    #Following: UI state initialization
    ui.graphicsView_preview.setVisible(False)
    ui.pushButton_preview_view.setChecked(False)
    
    ui.dockWidget_control.setVisible(False)
    
    #Following: Set paint refresh timer
    refresh_timer = QtCore.QTimer()
    refresh_timer.start(50)

    #Connect time out signal to paint operation
    refresh_timer.timeout.connect(paint_wave)

    #Following: New graphics scene object
    ui.scene = QtGui.QGraphicsScene()
    ui.scene.setBackgroundBrush(QtCore.Qt.black)

    #Following: Add wave item to the scene
    wave_item = Wave(scene = ui.scene)
    ui.scene.addItem(wave_item)

    #Following: Set graphics scene to graphics view object
    ui.graphicsView_wave.setScene(ui.scene)
    
    paint_grid()
    
    MainWindow.show()
    exit_val = app.exec_() #Execute app

    sp.kill() #Kill subprocess
    sys.exit(exit_val)
