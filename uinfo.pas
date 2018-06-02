unit uInfo;

{
  Kill those bothersome files with KBF.

  Kill Bothersome Files - kills those bothersome files, that get in the way.

  KBF Build Version :: 13 - Built at - 20/09/2017 22:43:01



  Copyright (C) Kevin Scott (c) 2012 - 2017. - kbf<at>keleven<dot>co<dot>uk


  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 3 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
  Boston, MA 02110-1335, USA.

  Also see GNU GENERAL PUBLIC LICENSE.txt is application directory.
}


{  Defines some constants, that are used in the Application.  }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  myName     = 'Kevin Scott (c) 2012 - 2018.';
  appName    = ' KBF ';
  myEmail    = 'kbf<at>keleven<dot>co<dot>uk';
  appVersion = 'KBF Build Version :: 15';
                                             //  constants used in TfrmMain.FileSizeToHumanReadableString
  OneKB = Int64(1024);
  OneMB = Int64(1024) * OneKB;
  OneGB = Int64(1024) * OneMB;
  OneTB = Int64(1024) * OneGB;
  OnePB = Int64(1024) * OneTB;
  fmt   = '#.###';

implementation

end.

