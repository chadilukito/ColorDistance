Program ProjectTest;
{$mode objfpc}

uses Classes, TextTestRunner, test;
 
begin
  // Register all tests
  test.RegisterTests;
 
  RunRegisteredTests;
end.