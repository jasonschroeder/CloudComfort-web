<link href="/markdown.css" rel="stylesheet"></link>

# CloudComfort Technical Writeup #

by [Jason Schroeder](https://github.com/jasonschroeder-sfdc) and [Ashish Mody](https://github.com/ashishmody)

CloudComfort is an application designed to help a user remotely control the temperature of an Air Conditioning (A/C) system.
The Arduino is used to connect the A/C to the Internet, receive messages to turn on or off the A/C, measure the temperature of the room, as well as adjust the temperature and fan speed accordingly.

The Ethernet shield connects the Arduino to the Internet and communicates with the CloudComfort web API. The Arduino polls the web application at constant intervals and reports the current temperature of the room.

For a promotional video, please visit [YouTube](http://www.youtube.com/watch?v=j8wE6YweumE)


## Web Application ##

The web console is the interface visible to the user. The CloudComfort website is a Ruby application running on [Heroku](http://www.heroku.com), built with [Sinara](http://www.sinatrarb.com/). The pages use [jQuery Mobile](http://www.jquerymobile.com/) JavaScript and CSS, making it mobile-friendly. This can be accessed using any browser (tablet/PC/smartphone) by pointing to [http://cloudcomfort.heroku.com/](http://cloudcomfort.heroku.com).

The user interface displays the current room temperature along with the date and time that it was last measured.  The user can select the A/C power settings, desired temperature and the fan speed, and press the save button to commit changes. The settings are persisted in a `memcached` server on Heroku, but this could be swapped for another database engine when supporting more than one A/C unit.

The power, temperature, and fan settings can be returned to the Arduino after each network connection. The web application has one API, which is used to report the temperature of the environment, and returns the user's desired power, temperature, and fan settings in the HTTP response.

## Web API ##

There is only one web API, `/api/1/poll`

The Arduino sends a HTTP form POST to the web API, with the room temperature:

    POST /api/1/poll HTTP/1.1
    Host: cloudcomfort.heroku.com
    Content-Length: 8
    Content-Type: application/x-www-form-urlencoded

    tempc=30



The server then replies with the current settings in a `key=value` format:

    HTTP/1.1 200 OK
    Server: nginx/0.7.67
    Date: Wed, 04 Jan 2012 02:43:14 GMT
    Content-Type: text/html;charset=utf-8
    Connection: keep-alive
    X-Frame-Options: sameorigin
    X-Xss-Protection: 1; mode=block
    Content-Length: 23
    
    ac=1
    tempc=26
    fan=0


## Arduino ##

The CloudComfort Arduino device powers up and gets an IP address using the Ethernet library included with the Arduino SDK. Once connected to the network, it goes into a loop and periodically sends a HTTP POST request to the CloudComfort web API with the current temperature value. The HTTP response includes the most recent settings from the web interface.

![Schematic](schematic.png)

The Arduino has a temperature sensor (TMP36) connected to the analog input pin `A0`. The Arduino measures the temperature as a linear voltage from 0.1 V to 2.0 V, representing -40° C to 150° C. This integer is sent to the web application in a HTTP POST. 

The IR transmitter is connected to the digital output pin `D3` of the Arduino. Whenever the Arduino detects a change in the desired A/C settings, the appropriate IR signals are transmitted from this IR LED. 

During the research phase, IR signals from the A/C's remote were recorded and a set of commands was built to emulate the buttons on the remote control.   The [Arduino-IRremote](https://github.com/shirriff/Arduino-IRremote) library by [Ken Shirriff](http://arcfn.com/2009/08/multi-protocol-infrared-remote-library.html) was used to record, decode, and transmit IR signals to the A/C.



## Next Steps ##
Supporting multiple Arduinos connecting to the API.  

## Contact Us ##
If you would like more information regarding this project, please reach out to [Jason Schroeder](https://github.com/jasonschroeder-sfdc) and [Ashish Mody](https://github.com/ashishmody)

