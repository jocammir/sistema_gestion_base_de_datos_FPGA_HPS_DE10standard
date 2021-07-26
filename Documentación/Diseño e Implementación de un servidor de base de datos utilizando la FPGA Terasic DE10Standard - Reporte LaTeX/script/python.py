from matplotlib import pyplot as plt #Importa pyplot para realizar la grafica.
from matplotlib import animation  #Importa animation que permite actualizar la grafica en intervalos concretos
from matplotlib import style #Permite cambiar el estilo de nuestra grafica.
import serial #Importa libreria para trabajar con el puerto serie.


style.use('fivethirtyeight')  #Cambia el estilo de nuestra grafica.

fig = plt.figure() #Creamos un objeto para almacenar el la grafica.



ax1 = fig.add_subplot(2,2,1) #Anadimos una "subgrafica" a nuestra ventana.

ax2 = fig.add_subplot(2,2,2) #Anadimos una "subgrafica" a nuestra ventana.

ax3 = fig.add_subplot(2,2,3) #Anadimos una "subgrafica" a nuestra ventana.

ax4 = fig.add_subplot(2,2,4) #Anadimos una "subgrafica" a nuestra ventana.

ser = serial.Serial('COM3', 9600) #Abrimos puerto Serie, sustituir 'dev/ttyUSB0', por 'COM2', 'COM3' o el puerto que use el Arduino en tu PC.
ser.timeout = 1
ser.setDTR(False)
ser.flushInput()
ser.setDTR(True)
ser.readline()
rojoPot1 = 230
rojoPot2 = 250
rojoTemp1 = 19.00
rojoTemp2 = 24.00

metering = input("Aplicar Calidad de Servicio?(s/n): ")
def plotea (i):
     temperatura = []
     pot = []
     temperatura1 = []
     pot1 = []
     muestras= 20
     for i in range(0,muestras): #Bucle for para recibir 100 valores anets de pintarlos.

          datoString = ser.readline()  #Leemos una linea enviada (hasta que se recibe el caracter \n).

          datos = str(datoString).split(",")
          if(metering == 's'):
               if(len(datos[0][2:])!=0):
                    if(float(datos[0][2:])>rojoTemp1):
                         temperatura.append (str(rojoTemp1))

                    else:
                         temperatura.append (datos[0][2:])
               if(len(datos[1]) !=0 ):
                    if(int(datos[1])>rojoPot1):
                          pot.append (str(rojoPot1))

                    else:
                          pot.append (datos[1])
               if(len(datos[2]) !=0):
                  if(float(datos[2])>rojoTemp2):
                       temperatura1.append (str(rojoTemp2))

                  else:
                       temperatura1.append (datos[2])
               if( len(datos[3][:-5]) !=0):
                  if(int(datos[3][:-5])>rojoPot2):
                       pot1.append (str(rojoPot2))

                  else:
                       pot1.append (datos[3][:-5])
          else:
              temperatura.append (datos[0][2:])
              pot.append (datos[1])
              temperatura1.append (datos[2])
              pot1.append (datos[3][:-5])

     ax1.clear() #Limpiamos la grafica para volver a pintar.
     ax1.set_ylim([0,20]) #Ajustamos el limite vertical de la grafica.
     ax2.clear() #Limpiamos la grafica para volver a pintar.
     ax2.set_ylim([0,18]) #Ajustamos el limite vertical de la grafica.
     ax3.clear() #Limpiamos la grafica para volver a pintar.
     ax3.set_ylim([0,20]) #Ajustamos el limite vertical de la grafica.
     ax4.clear() #Limpiamos la grafica para volver a pintar.
     ax4.set_ylim([0,18]) #Ajustamos el limite vertical de la grafica.

     try:  #Nos permite comprobar si hay un error al ejecutar la siguiente instruccion.
         ax1.plot(range(0,muestras), temperatura) # Plotea los datos en x de 0 a 100.
         ax2.plot(range(0,muestras), pot) # Plotea los datos en x de 0 a 100.
         ax3.plot(range(0,muestras), temperatura1) # Plotea los datos en x de 0 a 100.
         ax4.plot(range(0,muestras), pot1) # Plotea los datos en x de 0 a 100.
     except UnicodeDecodeError: #Si se produce el error al plotear no hacemos nada y evitamos que el programa se pare.
        pass

ani = animation.FuncAnimation(fig, plotea, interval = 1) #Creamos animacion para que se ejecute la funcion plotea con un intervalo de 1ms.

plt.show() #Muestra la grafica.
