// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: non_constant_identifier_names

// ignore: avoid_classes_with_only_static_members
/// A class containing the GUID references for each of the documented Windows
/// known folders. A property of this class may be passed to the `getPath`
/// method in the [PathProvidersWindows] class to retrieve a known folder from
/// Windows.
// These constants come from
// https://learn.microsoft.com/windows/win32/shell/knownfolderid
class WindowsKnownFolder {
  /// The file system directory that is used to store administrative tools for
  /// an individual user. The MMC will save customized consoles to this
  /// directory, and it will roam with the user.
  static String get AdminTools => '{724EF170-A42D-4FEF-9F26-B60E846FBA4F}';

  /// The file system directory that acts as a staging area for files waiting to
  /// be written to a CD. A typical path is C:\Documents and
  /// Settings\username\Local Settings\Application Data\Microsoft\CD Burning.
  static String get CDBurning => '{9E52AB10-F80D-49DF-ACB8-4330F5687855}';

  /// The file system directory that contains administrative tools for all users
  /// of the computer.
  static String get CommonAdminTools =>
      '{D0384E7D-BAC3-4797-8F14-CBA229B392B5}';

  /// The file system directory that contains the directories for the common
  /// program groups that appear on the Start menu for all users. A typical path
  /// is C:\Documents and Settings\All Users\Start Menu\Programs.
  static String get CommonPrograms => '{0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8}';

  /// The file system directory that contains the programs and folders that
  /// appear on the Start menu for all users. A typical path is C:\Documents and
  /// Settings\All Users\Start Menu.
  static String get CommonStartMenu => '{A4115719-D62E-491D-AA7C-E74B8BE3B067}';

  /// The file system directory that contains the programs that appear in the
  /// Startup folder for all users. A typical path is C:\Documents and
  /// Settings\All Users\Start Menu\Programs\Startup.
  static String get CommonStartup => '{82A5EA35-D9CD-47C5-9629-E15D2F714E6E}';

  /// The file system directory that contains the templates that are available
  /// to all users. A typical path is C:\Documents and Settings\All
  /// Users\Templates.
  static String get CommonTemplates => '{B94237E7-57AC-4347-9151-B08C6C32D1F7}';

  /// The virtual folder that represents My Computer, containing everything on
  /// the local computer: storage devices, printers, and Control Panel. The
  /// folder can also contain mapped network drives.
  static String get ComputerFolder => '{0AC0837C-BBF8-452A-850D-79D08E667CA7}';

  /// The virtual folder that represents Network Connections, that contains
  /// network and dial-up connections.
  static String get ConnectionsFolder =>
      '{6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD}';

  /// The virtual folder that contains icons for the Control Panel applications.
  static String get ControlPanelFolder =>
      '{82A74AEB-AEB4-465C-A014-D097EE346D63}';

  /// The file system directory that serves as a common repository for Internet
  /// cookies. A typical path is C:\Documents and Settings\username\Cookies.
  static String get Cookies => '{2B0F765D-C0E9-4171-908E-08A611B84FF6}';

  /// The virtual folder that represents the Windows desktop, the root of the
  /// namespace.
  static String get Desktop => '{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}';

  /// The virtual folder that represents the My Documents desktop item.
  static String get Documents => '{FDD39AD0-238F-46AF-ADB4-6C85480369C7}';

  /// The file system directory that serves as a repository for Internet
  /// downloads.
  static String get Downloads => '{374DE290-123F-4565-9164-39C4925E467B}';

  /// The file system directory that serves as a common repository for the
  /// user's favorite items. A typical path is C:\Documents and
  /// Settings\username\Favorites.
  static String get Favorites => '{1777F761-68AD-4D8A-87BD-30B759FA33DD}';

  /// A virtual folder that contains fonts. A typical path is C:\Windows\Fonts.
  static String get Fonts => '{FD228CB7-AE11-4AE3-864C-16F3910AB8FE}';

  /// The file system directory that serves as a common repository for Internet
  /// history items.
  static String get History => '{D9DC8A3B-B784-432E-A781-5A1130A75963}';

  /// The file system directory that serves as a common repository for temporary
  /// Internet files. A typical path is C:\Documents and Settings\username\Local
  /// Settings\Temporary Internet Files.
  static String get InternetCache => '{352481E8-33BE-4251-BA85-6007CAEDCF9D}';

  /// A virtual folder for Internet Explorer.
  static String get InternetFolder => '{4D9F7874-4E0C-4904-967B-40B0D20C3E4B}';

  /// The file system directory that serves as a data repository for local
  /// (nonroaming) applications. A typical path is C:\Documents and
  /// Settings\username\Local Settings\Application Data.
  static String get LocalAppData => '{F1B32785-6FBA-4FCF-9D55-7B8E7F157091}';

  /// The file system directory that serves as a common repository for music
  /// files. A typical path is C:\Documents and Settings\User\My Documents\My
  /// Music.
  static String get Music => '{4BD8D571-6D19-48D3-BE97-422220080E43}';

  /// A file system directory that contains the link objects that may exist in
  /// the My Network Places virtual folder. A typical path is C:\Documents and
  /// Settings\username\NetHood.
  static String get NetHood => '{C5ABBF53-E17F-4121-8900-86626FC2C973}';

  /// The folder that represents other computers in your workgroup.
  static String get NetworkFolder => '{D20BEEC4-5CA8-4905-AE3B-BF251EA09B53}';

  /// The file system directory that serves as a common repository for image
  /// files. A typical path is C:\Documents and Settings\username\My
  /// Documents\My Pictures.
  static String get Pictures => '{33E28130-4E1E-4676-835A-98395C3BC3BB}';

  /// The file system directory that contains the link objects that can exist in
  /// the Printers virtual folder. A typical path is C:\Documents and
  /// Settings\username\PrintHood.
  static String get PrintHood => '{9274BD8D-CFD1-41C3-B35E-B13F55A758F4}';

  /// The virtual folder that contains installed printers.
  static String get PrintersFolder => '{76FC4E2D-D6AD-4519-A663-37BD56068185}';

  /// The user's profile folder. A typical path is C:\Users\username.
  /// Applications should not create files or folders at this level.
  static String get Profile => '{5E6C858F-0E22-4760-9AFE-EA3317B67173}';

  /// The file system directory that contains application data for all users. A
  /// typical path is C:\Documents and Settings\All Users\Application Data. This
  /// folder is used for application data that is not user specific. For
  /// example, an application can store a spell-check dictionary, a database of
  /// clip art, or a log file in the CSIDL_COMMON_APPDATA folder. This
  /// information will not roam and is available to anyone using the computer.
  static String get ProgramData => '{62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}';

  /// The Program Files folder. A typical path is C:\Program Files.
  static String get ProgramFiles => '{905e63b6-c1bf-494e-b29c-65b732d3d21a}';

  /// The common Program Files folder. A typical path is C:\Program
  /// Files\Common.
  static String get ProgramFilesCommon =>
      '{F7F1ED05-9F6D-47A2-AAAE-29D317C6F066}';

  /// On 64-bit systems, a link to the common Program Files folder. A typical path is
  /// C:\Program Files\Common Files.
  static String get ProgramFilesCommonX64 =>
      '{6365D5A7-0F0D-45e5-87F6-0DA56B6A4F7D}';

  /// On 64-bit systems, a link to the 32-bit common Program Files folder. A
  /// typical path is C:\Program Files (x86)\Common Files. On 32-bit systems, a
  /// link to the Common Program Files folder.
  static String get ProgramFilesCommonX86 =>
      '{DE974D24-D9C6-4D3E-BF91-F4455120B917}';

  /// On 64-bit systems, a link to the Program Files folder. A typical path is
  /// C:\Program Files.
  static String get ProgramFilesX64 => '{6D809377-6AF0-444b-8957-A3773F02200E}';

  /// On 64-bit systems, a link to the 32-bit Program Files folder. A typical
  /// path is C:\Program Files (x86). On 32-bit systems, a link to the Common
  /// Program Files folder.
  static String get ProgramFilesX86 => '{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}';

  /// The file system directory that contains the user's program groups (which
  /// are themselves file system directories).
  static String get Programs => '{A77F5D77-2E2B-44C3-A6A2-ABA601054A51}';

  /// The file system directory that contains files and folders that appear on
  /// the desktop for all users. A typical path is C:\Documents and Settings\All
  /// Users\Desktop.
  static String get PublicDesktop => '{C4AA340D-F20F-4863-AFEF-F87EF2E6BA25}';

  /// The file system directory that contains documents that are common to all
  /// users. A typical path is C:\Documents and Settings\All Users\Documents.
  static String get PublicDocuments => '{ED4824AF-DCE4-45A8-81E2-FC7965083634}';

  /// The file system directory that serves as a repository for music files
  /// common to all users. A typical path is C:\Documents and Settings\All
  /// Users\Documents\My Music.
  static String get PublicMusic => '{3214FAB5-9757-4298-BB61-92A9DEAA44FF}';

  /// The file system directory that serves as a repository for image files
  /// common to all users. A typical path is C:\Documents and Settings\All
  /// Users\Documents\My Pictures.
  static String get PublicPictures => '{B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5}';

  /// The file system directory that serves as a repository for video files
  /// common to all users. A typical path is C:\Documents and Settings\All
  /// Users\Documents\My Videos.
  static String get PublicVideos => '{2400183A-6185-49FB-A2D8-4A392A602BA3}';

  /// The file system directory that contains shortcuts to the user's most
  /// recently used documents. A typical path is C:\Documents and
  /// Settings\username\My Recent Documents.
  static String get Recent => '{AE50C081-EBD2-438A-8655-8A092E34987A}';

  /// The virtual folder that contains the objects in the user's Recycle Bin.
  static String get RecycleBinFolder =>
      '{B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC}';

  /// The file system directory that contains resource data. A typical path is
  /// C:\Windows\Resources.
  static String get ResourceDir => '{8AD10C31-2ADB-4296-A8F7-E4701232C972}';

  /// The file system directory that serves as a common repository for
  /// application-specific data. A typical path is C:\Documents and
  /// Settings\username\Application Data.
  static String get RoamingAppData => '{3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}';

  /// The file system directory that contains Send To menu items. A typical path
  /// is C:\Documents and Settings\username\SendTo.
  static String get SendTo => '{8983036C-27C0-404B-8F08-102D10DCFD74}';

  /// The file system directory that contains Start menu items. A typical path
  /// is C:\Documents and Settings\username\Start Menu.
  static String get StartMenu => '{625B53C3-AB48-4EC1-BA1F-A1EF4146FC19}';

  /// The file system directory that corresponds to the user's Startup program
  /// group. The system starts these programs whenever the associated user logs
  /// on. A typical path is C:\Documents and Settings\username\Start
  /// Menu\Programs\Startup.
  static String get Startup => '{B97D20BB-F46A-4C97-BA10-5E3608430854}';

  /// The Windows System folder. A typical path is C:\Windows\System32.
  static String get System => '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}';

  /// The 32-bit Windows System folder. On 32-bit systems, this is typically
  /// C:\Windows\system32. On 64-bit systems, this is typically
  /// C:\Windows\syswow64.
  static String get SystemX86 => '{D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}';

  /// The file system directory that serves as a common repository for document
  /// templates. A typical path is C:\Documents and Settings\username\Templates.
  static String get Templates => '{A63293E8-664E-48DB-A079-DF759E0509F7}';

  /// The file system directory that serves as a common repository for video
  /// files. A typical path is C:\Documents and Settings\username\My
  /// Documents\My Videos.
  static String get Videos => '{18989B1D-99B5-455B-841C-AB7C74E4DDFC}';

  /// The Windows directory or SYSROOT. This corresponds to the %windir% or
  /// %SYSTEMROOT% environment variables. A typical path is C:\Windows.
  static String get Windows => '{F38BF404-1D43-42F2-9305-67DE0B28FC23}';
}
