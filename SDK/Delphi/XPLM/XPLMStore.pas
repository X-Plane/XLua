{
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
}

UNIT XPLMStore;
INTERFACE
{
   This API provides file access for store-managed plugins - plugins installed
   and kept up to date by the in-simulator store addon library.
}

USES
    XPLMDefs;
   {$A4}

TYPE
   XPLMChar   = AnsiChar;
   XPLMString = PAnsiChar;
   PXPLMString = ^XPLMString;

CONST
{$IFDEF MSWINDOWS}
   XPLM_DLL = 'XPLM_64.dll';
{$ENDIF}
{$IFDEF DARWIN}
   XPLM_DLL = 'XPLM.framework/XPLM';
{$ENDIF}
{$IFDEF LINUX}
   XPLM_DLL = 'XPLM_64.so';
{$ENDIF}
{___________________________________________________________________________
 * STORE FILE ACCESS
 ___________________________________________________________________________}

{$IFDEF XPLM460}
   {
    XPLMIsStoreManagedPlugin
    
    Returns non-zero if the calling plugin is a store-managed plugin.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMIsStoreManagedPlugin: Integer;
    cdecl; external XPLM_DLL;
{$ENDIF XPLM460}

{$IFDEF XPLM460}
   {
    XPLMDecryptResult
    
    These enums define the result of a decryption operation.
   }
TYPE
   XPLMDecryptResult = (
     { Decryption succeeded                                                       }
      xplmDecrypt_Ok                           = 1
 
     { Decryption failed, the calling plugin is not allowed to decrypt requested  }
     { file                                                                       }
     ,xplmDecrypt_NotAllowed                   = -1
 
     { Decryption failed due to a file error.                                     }
     ,xplmDecrypt_FileError                    = -2
 
   );
   PXPLMDecryptResult = ^XPLMDecryptResult;
{$ENDIF XPLM460}

{$IFDEF XPLM460}
   {
    XPLMStoreDecryptFile
    
                    Decrypts a store-managed file belonging to the same product
                    as the calling plugin. Path must be relative to the
                    X-System folder. Returns xplmDecrypt_Ok on success, another
                    XPLMDecryptResult value on failure. On success outBuf is
                    set to a pointer to the resulting buffer. Pass outBuf to
                    XPLMStoreFileFree() when done.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMStoreDecryptFile(
                                        inFilePath          : XPLMString;
                                        outBuf              : Ppointer;    { Can be nil }
                                        outBufSize          : PInteger) : Integer;    { Can be nil }
    cdecl; external XPLM_DLL;
{$ENDIF XPLM460}

{$IFDEF XPLM460}
   {
    XPLMStoreLoadFile
    
                    Loads a store-managed file belonging to the same product as
                    the calling plugin. Path must be relative to the X-System
                    folder. Returns 1 on success, 0 or a negative errno-style
                    value on failure. On success outBuf is set to a pointer to
                    the resulting buffer (left NULL for an empty file). Pass
                    outBuf to XPLMStoreFileFree() when done.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMStoreLoadFile(
                                        inFilePath          : XPLMString;
                                        outBuf              : Ppointer;    { Can be nil }
                                        outBufSize          : PInteger) : Integer;    { Can be nil }
    cdecl; external XPLM_DLL;
{$ENDIF XPLM460}


{$IFDEF XPLM460}
   {
    XPLMStoreFileFree
    
                    Frees the buffer allocated by XPLMStoreDecryptFile() or
                    XPLMStoreLoadFile().
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMStoreFileFree(
                                        inBuf               : pointer);    { Can be nil }
    cdecl; external XPLM_DLL;
{$ENDIF XPLM460}

{$IFDEF XPLM460}
   {
    XPLMStoreIsEncrypted
    
                    Checks whether a store-managed file belonging to the same
                    product as the calling plugin is encrypted. Path must be
                    relative to the X-System folder. Returns 1 if the file is
                    encrypted, 0 if it is not encrypted, and -1 on error (the
                    calling plugin is not store-managed, the file is not a
                    known store-managed file, or it does not belong to the same
                    product as the calling plugin).
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMStoreIsEncrypted(
                                        inFilePath          : XPLMString) : Integer;
    cdecl; external XPLM_DLL;
{$ENDIF XPLM460}

{___________________________________________________________________________
 * Host API
 ___________________________________________________________________________}

CONST
   XPLMStoreHostApiVersion = 0;








IMPLEMENTATION

END.
