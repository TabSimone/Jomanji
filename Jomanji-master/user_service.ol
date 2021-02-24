include "UserInterface.iol"
include "console.iol"


execution{ concurrent }

inputPort User {
  Location: LOCATION
  Protocol: sodep
  Interfaces: UserInterface
}