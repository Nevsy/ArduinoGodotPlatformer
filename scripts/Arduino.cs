using Godot;
using System;
using System.IO.Ports;

public partial class Arduino : Node2D
{
	SerialPort serialPort;
	CharacterBody2D gdScript;

	string message;
	string buff;
	int serialInt;
	
	string stringWereGoingToSend;
	
	public override void _Ready()
	{
		//text = GetNode<RichTextLabel>("RichTextLabel");
		serialPort = new SerialPort("COM6", 9600);
		serialPort.Open();
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
		//text.Text = "1"; 
	}
	
	public void healthLedUpdate(int heartsLeft){
		stringWereGoingToSend = "";
		for(int i = 0; i < heartsLeft; i++){
			stringWereGoingToSend += 'a';
		}
		stringWereGoingToSend += "///";
		GD.Print(stringWereGoingToSend);
		serialPort.Write(stringWereGoingToSend);
	}
}
