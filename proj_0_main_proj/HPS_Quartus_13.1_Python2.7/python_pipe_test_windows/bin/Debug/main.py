#/usr/bin/python
import subprocess ,time, sys
from PyQt4 import QtCore ,  QtGui
#import math


class DotsWindow(QtGui.QWidget):
        Data_Length = 1024
        Data_Arr = range(Data_Length) #Init Array
        
        def __init__(self):
                super(DotsWindow,self).__init__()
                self.Refresher = QtCore.QTimer(self)
                self.Refresher.start(50)
                self.Refresher.timeout.connect(self.wave_refresh)
                self.sp = subprocess.Popen("python_pipe_test",stdin = subprocess.PIPE, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        def wave_refresh(self):
                self.sp.stdin.write('s\n')
                self.sp.stdin.flush()
                for i in range(self.Data_Length):
                        message = self.sp.stdout.readline()
                        self.Data_Arr[i] = int(message)
                self.update()
        def paintEvent(self,e):
                qp = QtGui.QPainter()
                qp.begin(self)
                qp.setPen(QtCore.Qt.red)
                for i in range(self.Data_Length):
                        qp.drawPoint(i,self.Data_Arr[i])
                qp.end()

	
def main():
        app = QtGui.QApplication(sys.argv)
        w = DotsWindow()
        w.resize(1000,500)
        w.setWindowTitle('Oscilloscope Waveform')
	
        w.show()
        sys.exit(app.exec_())

main()
