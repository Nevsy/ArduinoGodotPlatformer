using Godot;
using System;
using System.IO.Ports;

using System.Threading;

public partial class Arduino : Node2D
{
	SerialPort serialPort;
	CharacterBody2D gdScript;

	string message;
	string buff;
	int serialInt;
	
	string stringWereGoingToSend;
	
	bool serialPortInitialized = false;
	
	public override void _Ready()
	{
		serialPort = new SerialPort("COM3", 9600);
		serialPort.Open();
		serialPortInitialized = true;
		serialPort.Write("c"); //init haerts to 3
		
		message = serialPort.ReadExisting();
		
		gdScript = GetNode<CharacterBody2D>("Player");
	}
	
	public override void _Process(double delta)
	{
		message = serialPort.ReadExisting(); // Read data from serial port (readExisting > ReadLine (super laggy!!!) for single chars), Int32.Parse(serialPort.ReadLine()); for ints
		//message = serialPort.ReadLine(); LAGGY!!!
		if (message[0].Equals('a')) return;
		foreach(char c in message){
			if(c.Equals('\n')){
				serialInt = int.Parse(buff);
				gdScript.Call("addButtonValue", serialInt);
				buff = "";
				continue;
			}
			buff += c;
		}
	}
	
	public void healthLedUpdate(int heartsLeft){
		// This method is not working, why?
		
		//stringWereGoingToSend = "";
		//for(int i = 0; i < heartsLeft; i++){
			//stringWereGoingToSend += 'a';
		//}
		//stringWereGoingToSend += "///";
		//GD.Print(stringWereGoingToSend);
		//serialPort.Write(stringWereGoingToSend);
		
		switch (heartsLeft) {
			case 3:
				serialPort.Write("c");
				break;
			case 2:
				serialPort.Write("b");
				break;
			case 1:
				serialPort.Write("a");
				break;
			case 0:
				serialPort.Write("/");
				break;
			default:
				GD.Print("INPUT ERROR");
				break;
		}
	}
}
