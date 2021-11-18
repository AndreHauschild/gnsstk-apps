//==============================================================================
//
//  This file is part of GNSSTk, the ARL:UT GNSS Toolkit.
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

/** \page apps
 * - \subpage rmwcheck - Determine if a file is valid RINEX MET
 * \page rmwcheck
 * \tableofcontents
 *
 * \section rmwcheck_name NAME
 * rmwcheck - Determine if a file is valid RINEX MET
 *
 * \section rmwcheck_synopsis SYNOPSIS
 * \b rmwcheck [\argarg{OPTION}] ... [\argarg{FILE}] ...
 *
 * \section rmwcheck_description DESCRIPTION
 * Attempt to read files as RINEX MET data, to determine if they are
 * correctly formatted.
 *
 * \dictionary
 * \dicterm{-d, \--debug}
 * \dicdef{Increase debug level}
 * \dicterm{-v, \--verbose}
 * \dicdef{Increase verbosity}
 * \dicterm{-h, \--help}
 * \dicdef{Print help usage}
 * \dicterm{-1, \--quit-on-first-error}
 * \dicdef{Quit on the first error encountered (default = no).}
 * \dicterm{-t, \--time=\argarg{TIME}}
 * \dicdef{Start of time range to compare (default = "beginning of time")}
 * \dicterm{-e, \--end-time=\argarg{TIME}}
 * \dicdef{End of time range to compare (default = "end of time")}
 * \enddictionary
 *
 * Time may be specified in one of three formats:
 * - month/day/year
 * - year day-of-year
 * - year day-of-year seconds-of-day
 *
 * \section rmwcheck_examples EXAMPLES
 *
 * \cmdex{rmwcheck data/arlm200a.15m data/arlm200z.15m}
 *
 * Will process the two files and return 0 on success.
 *
 * \todo Add an example or two using the time options.
 *
 * \section rmwcheck_exit_status EXIT STATUS
 * The following exit values are returned:
 * \dictable
 * \dictentry{0,No errors ocurred\, input files are valid}
 * \dictentry{1,A C++ exception occurred\, or one or more files were invalid}
 * \enddictable
 *
 * \section rmwcheck_see_also SEE ALSO
 * \ref rnwcheck, \ref rowcheck
 */

#include "CheckFrame.hpp"

#include <gnsstk/RinexMetStream.hpp>
#include <gnsstk/RinexMetData.hpp>
#include <gnsstk/RinexMetFilterOperators.hpp>

using namespace std;
using namespace gnsstk;

int main(int argc, char* argv[])
{
   try
   {
      CheckFrame<RinexMetStream, RinexMetData, RinexMetDataFilterTime>
         cf(argv[0], "Rinex Met");

      if (!cf.initialize(argc, argv))
         return cf.exitCode;
      if (!cf.run())
         return cf.exitCode;

      return cf.exitCode;
   }
   catch(gnsstk::Exception& e)
   {
      cout << e << endl;
   }
   catch(std::exception& e)
   {
      cout << e.what() << endl;
   }
   catch(...)
   {
      cout << "unknown error" << endl;
   }
   return BasicFramework::EXCEPTION_ERROR;;
}
