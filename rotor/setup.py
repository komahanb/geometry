"""
Python script to setup the files necessary for flexible multibody
dynamics simulation in TACS.

The goal is to prepare:
.bdf : files for each body containing mesh for visualization
.inp : files for each body containing inertial properties and initial conditions

The mesh, inertial properties and initial conditions are required by
TACSBuilder class for creating TACS.

This script basically takes us from GEO to ANALYSIS.

Author: Komahan Boopathy (komahan@gatech.edu)
"""
class Body(object):
    def __init__(self, name, geofile, processBC):
        self.name = name
        self.geofile = geofile
        self.processBC = processBC

bodies = []
bodies.append(Body("bsp", False))
print bodies[0]

# All the bodies to setup for simulation
bodies.append(Body("bcap0"    , "BladeCapAt0Deg"         , False)
bodies.append(Body("bcap90"   , "BladeCapAt90Deg"        , False)
bodies.append(Body("bcap180"  , "BladeCapAt180Deg"       , False)
bodies.append(Body("bcap270"  , "BladeCapAt270Deg"       , False)
bodies.append(Body("blade0"   , "BladeAt0Deg"            , True)
bodies.append(Body("blade90"  , "BladeAt90Deg"           , True)
bodies.append(Body("blade180" , "BladeAt180Deg"          , True)
bodies.append(Body("blade270" , "BladeAt270Deg"          , True)
bodies.append(Body("lpl30"    , "LowerPitchLinkAt30Deg"  , False)
bodies.append(Body("lpl120"   , "LowerPitchLinkAt120Deg" , False)
bodies.append(Body("lpl210"   , "LowerPitchLinkAt210Deg" , False)
bodies.append(Body("lpl300"   , "LowerPitchLinkAt300Deg" , False)
bodies.append(Body("upl30"    , "UpperPitchLinkAt30Deg"  , False)
bodies.append(Body("upl120"   , "UpperPitchLinkAt120Deg" , False)
bodies.append(Body("upl210"   , "UpperPitchLinkAt210Deg" , False)
bodies.append(Body("upl300"   , "UpperPitchLinkAt300Deg" , False)
bodies.append(Body("hub4b"    , "Hub4Bladed"             , False)
bodies.append(Body("usp4b"    , "UpperSwashPlate4Bladed" , False)
bodies.append(Body("sphere"   , "Sphere"                 , False)
bodies.append(Body("bsp"      , "BasePlate"              , False)
bodies.append(Body("lsp"      , "LowerSwashPlate"        , False)
bodies.append(Body("prod90"   , "PushRodAt90Deg"         , False)
bodies.append(Body("prod180"  , "PushRodAt180Deg"        , False)
bodies.append(Body("prod270"  , "PushRodAt270Deg"        , False)
bodies.append(Body("lph"      , "LowerPushHorn"          , False)
bodies.append(Body("uph"      , "UpperPushHorn"          , False)
