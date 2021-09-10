//==============================================================================
//
//  This file is part of GNSSTk, the GNSS Toolkit.
//
//  The GNSSTk is free software; you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published
//  by the Free Software Foundation; either version 3.0 of the License, or
//  any later version.
//
//  The GNSSTk is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public
//  License along with GNSSTk; if not, write to the Free Software Foundation,
//  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
//  
//  This software was developed by Applied Research Laboratories at the
//  University of Texas at Austin.
//  Copyright 2004-2021, The Board of Regents of The University of Texas System
//
//==============================================================================

//==============================================================================
//
//  This software was developed by Applied Research Laboratories at the
//  University of Texas at Austin, under contract to an agency or agencies
//  within the U.S. Department of Defense. The U.S. Government retains all
//  rights to use, duplicate, distribute, disclose, or release this software.
//
//  Pursuant to DoD Directive 523024 
//
//  DISTRIBUTION STATEMENT A: This software has been approved for public 
//                            release, distribution is unlimited.
//
//==============================================================================

#include <iostream>
#include <string>
#include <cstring>
using std::istream;
using std::cout;
using std::endl;

#include "TCPStream.hpp"
#include "CommandOption.hpp"
#include "CommandOptionParser.hpp"

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/errno.h>

int main(int argc, char* argv[])
{
   try
   {
      gnsstk::SocketAddr client(std::string("localhost"), 4621);
      gnsstk::IPaddress any;
      gnsstk::SocketAddr server(any, 4621);
      int debugLevel = 0;
      gnsstk::CommandOptionNoArg
         debugOption('d', "debug", "Enable debug output."),
         serverOption('s', "server", "Run as server, not client");
      std::string appDescription("Test program for the TCPStream stuff.");
      gnsstk::CommandOptionParser cop(appDescription);
      cop.parseOptions(argc, argv);
      if (cop.hasErrors())
      {
         cop.dumpErrors(cout);
         cop.displayUsage(cout);
         exit(0);
      }

      debugLevel = debugOption.getCount();

      gnsstk::TCPStream tcpStream;

      if (serverOption.getCount())
      {
         cout << "Running as a server on " << server << endl;
         int listening_socket = ::socket(AF_INET,SOCK_STREAM,0);
         if (listening_socket < 0)
            cout << "Couldn't create listening socket"
                 << " (" << strerror(errno) << ")" << endl, exit(-1);
         
         int value = 1;
         int rc=0;
         
         if (::setsockopt(listening_socket, SOL_SOCKET, SO_REUSEADDR,
                          (char*)&value, sizeof(value)))
            cout << "Couldn't set reuse address"
                 << " (" << strerror(errno) << ")" << endl, exit(-1);
         
         if (::bind(listening_socket, (sockaddr *)server, sizeof(sockaddr)))
            cout << "Couldn't bind"
                 << " (" << strerror(errno) << ")" << endl, exit(-1);
         
         if (::listen(listening_socket, 5))
            cout << "Couldn't listen"
                 << " (" << strerror(errno) << ")" << endl, exit(-1);
         
         gnsstk::TCPStream link;
         gnsstk::SocketAddr peeraddr = gnsstk::SocketAddr(any,1);
         link.rdbuf()->accept(listening_socket,peeraddr);
         cout << "Accepted connection from " << peeraddr << endl;
         link.close();
      }
      else
      {
         cout << "Running as client, :" << client << endl;
         
         tcpStream.connect(client);
         if( !tcpStream.good() )
            cout << "Connection failed!" << endl, exit(0);
      }
   }
   catch (...)
   {
      cout << "Caught one" << endl;
   }
}
