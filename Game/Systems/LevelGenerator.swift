import Foundation
import CoreGraphics

// MARK: - Level Generator
final class LevelGenerator {

    // Generate a complete level progression with increasing difficulty
    static func generateLevelProgression() -> [LevelDefinition] {
        var levels: [LevelDefinition] = []

        // Tutorial Levels (1-3)
        levels.append(createTutorialLevel1())
        levels.append(createTutorialLevel2())
        levels.append(createTutorialLevel3())

        // Easy Levels (4-6)
        levels.append(createEasyLevel1())
        levels.append(createEasyLevel2())
        levels.append(createEasyLevel3())

        // Medium Levels (7-10)
        levels.append(createMediumLevel1())
        levels.append(createMediumLevel2())
        levels.append(createMediumLevel3())
        levels.append(createMediumLevel4())

        // Hard Levels (11-15)
        levels.append(createHardLevel1())
        levels.append(createHardLevel2())
        levels.append(createHardLevel3())
        levels.append(createHardLevel4())
        levels.append(createHardLevel5())

        return levels
    }

    // MARK: - Tutorial Levels

    static func createTutorialLevel1() -> LevelDefinition {
        LevelDefinition(
            id: "Level01",
            index: 1,
            title: "First Steps",
            sparkStart: CGPoint(x: 50, y: 180),
            vesperStart: CGPoint(x: 50, y: 100),
            sparkPortal: Portal(position: CGPoint(x: 350, y: 180), radius: 30),
            vesperPortal: Portal(position: CGPoint(x: 350, y: 100), radius: 30),
            windmills: [],
            bridges: [],
            heatPlates: [],
            iceWalls: [],
            surgeBarriers: [],
            flowBarriers: [],
            resonancePads: [],
            hazards: [],
            tuning: LevelTuning(
                targetTime: 30,
                checkpoints: [],
                hintTriggers: [
                    HintTrigger(failCount: 2, timeStuck: 10, hint: "Drag Spark to the golden portal"),
                    HintTrigger(failCount: 3, timeStuck: 15, hint: "Move Vesper to the blue portal")
                ],
                mechanicTeaching: MechanicTuning(
                    windPowerThreshold: 30,
                    heatMeltRate: 0.4,
                    refreezeRate: 0.12,
                    bridgeExtendSpeed: 60,
                    vesperFriction: 0.92,
                    sparkDragRadius: 60,
                    proximityGlowThreshold: 0.75,
                    surgeDecayRate: 0.995,
                    flowDecayRate: 0.99,
                    proximityMaxRange: 150
                )
            )
        )
    }

    static func createTutorialLevel2() -> LevelDefinition {
        LevelDefinition(
            id: "Level02",
            index: 2,
            title: "Wind Power",
            sparkStart: CGPoint(x: 50, y: 180),
            vesperStart: CGPoint(x: 50, y: 100),
            sparkPortal: Portal(position: CGPoint(x: 400, y: 200), radius: 30),
            vesperPortal: Portal(position: CGPoint(x: 400, y: 100), radius: 30),
            windmills: [
                Windmill(position: CGPoint(x: 200, y: 200), linkIndex: 1, threshold: 0.3)
            ],
            bridges: [
                Bridge(origin: CGPoint(x: 150, y: 140), maxWidth: 100, linkIndex: 1)
            ],
            heatPlates: [],
            iceWalls: [],
            surgeBarriers: [],
            flowBarriers: [],
            resonancePads: [],
            hazards: [
                Hazard(type: .void, position: CGPoint(x: 250, y: 120), size: CGSize(width: 100, height: 150))
            ],
            tuning: LevelTuning(
                targetTime: 45,
                checkpoints: [],
                hintTriggers: [
                    HintTrigger(failCount: 2, timeStuck: 15, hint: "Circle the windmill to generate power"),
                    HintTrigger(failCount: 4, timeStuck: 25, hint: "Wind power extends the bridge")
                ],
                mechanicTeaching: MechanicTuning.default
            )
        )
    }

    static func createTutorialLevel3() -> LevelDefinition {
        LevelDefinition(
            id: "Level03",
            index: 3,
            title: "Fire and Ice",
            sparkStart: CGPoint(x: 50, y: 180),
            vesperStart: CGPoint(x: 50, y: 100),
            sparkPortal: Portal(position: CGPoint(x: 450, y: 200), radius: 30),
            vesperPortal: Portal(position: CGPoint(x: 450, y: 100), radius: 30),
            windmills: [],
            bridges: [],
            heatPlates: [
                HeatPlate(position: CGPoint(x: 200, y: 180), radius: 35, linkIndex: 1)
            ],
            iceWalls: [
                IceWall(position: CGPoint(x: 300, y: 100), size: CGSize(width: 50, height: 80), linkIndex: 1, meltTime: 2.5)
            ],
            surgeBarriers: [],
            flowBarriers: [],
            resonancePads: [],
            hazards: [],
            tuning: LevelTuning(
                targetTime: 40,
                checkpoints: [CGPoint(x: 200, y: 150)],
                hintTriggers: [
                    HintTrigger(failCount: 2, timeStuck: 15, hint: "Stand on the heat plate to melt ice"),
                    HintTrigger(failCount: 3, timeStuck: 20, hint: "Ice blocks Vesper's path")
                ],
                mechanicTeaching: MechanicTuning.default
            )
        )
    }

    // MARK: - Easy Levels

    static func createEasyLevel1() -> LevelDefinition {
        LevelDefinition(
            id: "Level04",
            index: 4,
            title: "Parallel Paths",
            sparkStart: CGPoint(x: 30, y: 200),
            vesperStart: CGPoint(x: 30, y: 80),
            sparkPortal: Portal(position: CGPoint(x: 470, y: 200), radius: 30),
            vesperPortal: Portal(position: CGPoint(x: 470, y: 80), radius: 30),
            windmills: [
                Windmill(position: CGPoint(x: 150, y: 220), linkIndex: 1, threshold: 0.4),
                Windmill(position: CGPoint(x: 350, y: 220), linkIndex: 2, threshold: 0.4)
            ],
            bridges: [
                Bridge(origin: CGPoint(x: 100, y: 120), maxWidth: 80, linkIndex: 1),
                Bridge(origin: CGPoint(x: 300, y: 120), maxWidth: 80, linkIndex: 2)
            ],
            heatPlates: [],
            iceWalls: [],
            surgeBarriers: [],
            flowBarriers: [],
            resonancePads: [],
            hazards: [
                Hazard(type: .void, position: CGPoint(x: 180, y: 100), size: CGSize(width: 120, height: 60)),
                Hazard(type: .void, position: CGPoint(x: 380, y: 100), size: CGSize(width: 90, height: 60))
            ],
            tuning: LevelTuning(targetTime: 60, checkpoints: [], hintTriggers: [], mechanicTeaching: MechanicTuning.default)
        )
    }

    static func createEasyLevel2() -> LevelDefinition {
        LevelDefinition(
            id: "Level05",
            index: 5,
            title: "Timing Dance",
            sparkStart: CGPoint(x: 50, y: 150),
            vesperStart: CGPoint(x: 50, y: 150),
            sparkPortal: Portal(position: CGPoint(x: 450, y: 250), radius: 30),
            vesperPortal: Portal(position: CGPoint(x: 450, y: 50), radius: 30),
            windmills: [],
            bridges: [],
            heatPlates: [
                HeatPlate(position: CGPoint(x: 150, y: 200), radius: 40, linkIndex: 1),
                HeatPlate(position: CGPoint(x: 350, y: 100), radius: 40, linkIndex: 2)
            ],
            iceWalls: [
                IceWall(position: CGPoint(x: 250, y: 50), size: CGSize(width: 60, height: 100), linkIndex: 1, meltTime: 3),
                IceWall(position: CGPoint(x: 250, y: 200), size: CGSize(width: 60, height: 100), linkIndex: 2, meltTime: 3)
            ],
            surgeBarriers: [],
            flowBarriers: [],
            resonancePads: [],
            hazards: [],
            tuning: LevelTuning(targetTime: 70, checkpoints: [], hintTriggers: [], mechanicTeaching: MechanicTuning.default)
        )
    }

    static func createEasyLevel3() -> LevelDefinition {
        LevelDefinition(
            id: "Level06",
            index: 6,
            title: "Surge Shield",
            sparkStart: CGPoint(x: 50, y: 150),
            vesperStart: CGPoint(x: 450, y: 150),
            sparkPortal: Portal(position: CGPoint(x: 450, y: 250), radius: 30),
            vesperPortal: Portal(position: CGPoint(x: 50, y: 50), radius: 30),
            windmills: [],
            bridges: [],
            heatPlates: [],
            iceWalls: [],
            surgeBarriers: [
                SurgeBarrier(position: CGPoint(x: 250, y: 250), width: 200, threshold: 0.5)
            ],
            flowBarriers: [
                FlowBarrier(position: CGPoint(x: 250, y: 50), width: 200, threshold: 0.5)
            ],
            resonancePads: [],
            hazards: [],
            tuning: LevelTuning(
                targetTime: 55,
                checkpoints: [],
                hintTriggers: [
                    HintTrigger(failCount: 2, timeStuck: 20, hint: "Build surge to pass barriers"),
                    HintTrigger(failCount: 3, timeStuck: 30, hint: "Vesper needs flow energy")
                ],
                mechanicTeaching: MechanicTuning.default
            )
        )
    }

    // MARK: - Medium Levels

    static func createMediumLevel1() -> LevelDefinition {
        LevelDefinition(
            id: "Level07",
            index: 7,
            title: "Synchronized Swimming",
            sparkStart: CGPoint(x: 50, y: 250),
            vesperStart: CGPoint(x: 50, y: 50),
            sparkPortal: Portal(position: CGPoint(x: 450, y: 250), radius: 25),
            vesperPortal: Portal(position: CGPoint(x: 450, y: 50), radius: 25),
            windmills: [
                Windmill(position: CGPoint(x: 150, y: 200), linkIndex: 1, threshold: 0.5),
                Windmill(position: CGPoint(x: 350, y: 100), linkIndex: 2, threshold: 0.5)
            ],
            bridges: [
                Bridge(origin: CGPoint(x: 100, y: 150), maxWidth: 120, linkIndex: 1),
                Bridge(origin: CGPoint(x: 300, y: 150), maxWidth: 120, linkIndex: 2)
            ],
            heatPlates: [
                HeatPlate(position: CGPoint(x: 250, y: 250), radius: 30, linkIndex: 3)
            ],
            iceWalls: [
                IceWall(position: CGPoint(x: 200, y: 50), size: CGSize(width: 40, height: 60), linkIndex: 3, meltTime: 2),
                IceWall(position: CGPoint(x: 300, y: 50), size: CGSize(width: 40, height: 60), linkIndex: 3, meltTime: 2)
            ],
            surgeBarriers: [],
            flowBarriers: [],
            resonancePads: [
                ResonancePad(position: CGPoint(x: 250, y: 150), radius: 50)
            ],
            hazards: [
                Hazard(type: .void, position: CGPoint(x: 150, y: 50), size: CGSize(width: 50, height: 50)),
                Hazard(type: .void, position: CGPoint(x: 350, y: 250), size: CGSize(width: 50, height: 50))
            ],
            tuning: LevelTuning(targetTime: 90, checkpoints: [], hintTriggers: [], mechanicTeaching: MechanicTuning.default)
        )
    }

    static func createMediumLevel2() -> LevelDefinition {
        LevelDefinition(
            id: "Level08",
            index: 8,
            title: "Chain Reaction",
            sparkStart: CGPoint(x: 250, y: 150),
            vesperStart: CGPoint(x: 250, y: 150),
            sparkPortal: Portal(position: CGPoint(x: 50, y: 250), radius: 25),
            vesperPortal: Portal(position: CGPoint(x: 450, y: 50), radius: 25),
            windmills: [
                Windmill(position: CGPoint(x: 100, y: 200), linkIndex: 1, threshold: 0.4),
                Windmill(position: CGPoint(x: 200, y: 200), linkIndex: 2, threshold: 0.4),
                Windmill(position: CGPoint(x: 300, y: 200), linkIndex: 3, threshold: 0.4),
                Windmill(position: CGPoint(x: 400, y: 200), linkIndex: 4, threshold: 0.4)
            ],
            bridges: [
                Bridge(origin: CGPoint(x: 150, y: 100), maxWidth: 50, linkIndex: 1),
                Bridge(origin: CGPoint(x: 200, y: 100), maxWidth: 50, linkIndex: 2),
                Bridge(origin: CGPoint(x: 250, y: 100), maxWidth: 50, linkIndex: 3),
                Bridge(origin: CGPoint(x: 300, y: 100), maxWidth: 50, linkIndex: 4)
            ],
            heatPlates: [],
            iceWalls: [],
            surgeBarriers: [
                SurgeBarrier(position: CGPoint(x: 100, y: 250), width: 100, threshold: 0.6)
            ],
            flowBarriers: [
                FlowBarrier(position: CGPoint(x: 400, y: 50), width: 100, threshold: 0.6)
            ],
            resonancePads: [],
            hazards: [],
            tuning: LevelTuning(targetTime: 100, checkpoints: [], hintTriggers: [], mechanicTeaching: MechanicTuning.default)
        )
    }

    static func createMediumLevel3() -> LevelDefinition {
        LevelDefinition(
            id: "Level09",
            index: 9,
            title: "Mirror Maze",
            sparkStart: CGPoint(x: 50, y: 250),
            vesperStart: CGPoint(x: 450, y: 50),
            sparkPortal: Portal(position: CGPoint(x: 450, y: 250), radius: 25),
            vesperPortal: Portal(position: CGPoint(x: 50, y: 50), radius: 25),
            windmills: [],
            bridges: [],
            heatPlates: [
                HeatPlate(position: CGPoint(x: 150, y: 250), radius: 30, linkIndex: 1),
                HeatPlate(position: CGPoint(x: 350, y: 50), radius: 30, linkIndex: 2)
            ],
            iceWalls: [
                // Create a maze-like pattern
                IceWall(position: CGPoint(x: 100, y: 150), size: CGSize(width: 40, height: 100), linkIndex: 2, meltTime: 3),
                IceWall(position: CGPoint(x: 200, y: 150), size: CGSize(width: 40, height: 100), linkIndex: 1, meltTime: 3),
                IceWall(position: CGPoint(x: 300, y: 150), size: CGSize(width: 40, height: 100), linkIndex: 2, meltTime: 3),
                IceWall(position: CGPoint(x: 400, y: 150), size: CGSize(width: 40, height: 100), linkIndex: 1, meltTime: 3)
            ],
            surgeBarriers: [],
            flowBarriers: [],
            resonancePads: [
                ResonancePad(position: CGPoint(x: 250, y: 150), radius: 60)
            ],
            hazards: [],
            tuning: LevelTuning(targetTime: 110, checkpoints: [], hintTriggers: [], mechanicTeaching: MechanicTuning.default)
        )
    }

    static func createMediumLevel4() -> LevelDefinition {
        LevelDefinition(
            id: "Level10",
            index: 10,
            title: "Power Grid",
            sparkStart: CGPoint(x: 250, y: 250),
            vesperStart: CGPoint(x: 250, y: 50),
            sparkPortal: Portal(position: CGPoint(x: 450, y: 150), radius: 25),
            vesperPortal: Portal(position: CGPoint(x: 50, y: 150), radius: 25),
            windmills: [
                // Grid of windmills
                Windmill(position: CGPoint(x: 150, y: 200), linkIndex: 1, threshold: 0.3),
                Windmill(position: CGPoint(x: 250, y: 200), linkIndex: 2, threshold: 0.3),
                Windmill(position: CGPoint(x: 350, y: 200), linkIndex: 3, threshold: 0.3)
            ],
            bridges: [
                Bridge(origin: CGPoint(x: 100, y: 150), maxWidth: 100, linkIndex: 1),
                Bridge(origin: CGPoint(x: 200, y: 150), maxWidth: 100, linkIndex: 2),
                Bridge(origin: CGPoint(x: 300, y: 150), maxWidth: 100, linkIndex: 3)
            ],
            heatPlates: [],
            iceWalls: [],
            surgeBarriers: [
                SurgeBarrier(position: CGPoint(x: 450, y: 200), width: 50, threshold: 0.7),
                SurgeBarrier(position: CGPoint(x: 450, y: 100), width: 50, threshold: 0.7)
            ],
            flowBarriers: [
                FlowBarrier(position: CGPoint(x: 50, y: 200), width: 50, threshold: 0.7),
                FlowBarrier(position: CGPoint(x: 50, y: 100), width: 50, threshold: 0.7)
            ],
            resonancePads: [],
            hazards: [
                Hazard(type: .electric, position: CGPoint(x: 250, y: 150), size: CGSize(width: 100, height: 100))
            ],
            tuning: LevelTuning(targetTime: 120, checkpoints: [], hintTriggers: [], mechanicTeaching: MechanicTuning.default)
        )
    }

    // MARK: - Hard Levels

    static func createHardLevel1() -> LevelDefinition {
        LevelDefinition(
            id: "Level11",
            index: 11,
            title: "Quantum Entanglement",
            sparkStart: CGPoint(x: 50, y: 150),
            vesperStart: CGPoint(x: 450, y: 150),
            sparkPortal: Portal(position: CGPoint(x: 250, y: 250), radius: 20),
            vesperPortal: Portal(position: CGPoint(x: 250, y: 50), radius: 20),
            windmills: [
                Windmill(position: CGPoint(x: 150, y: 250), linkIndex: 1, threshold: 0.6),
                Windmill(position: CGPoint(x: 350, y: 50), linkIndex: 2, threshold: 0.6)
            ],
            bridges: [],
            heatPlates: [
                HeatPlate(position: CGPoint(x: 100, y: 150), radius: 25, linkIndex: 3),
                HeatPlate(position: CGPoint(x: 400, y: 150), radius: 25, linkIndex: 4)
            ],
            iceWalls: [
                IceWall(position: CGPoint(x: 250, y: 200), size: CGSize(width: 150, height: 30), linkIndex: 3, meltTime: 4),
                IceWall(position: CGPoint(x: 250, y: 100), size: CGSize(width: 150, height: 30), linkIndex: 4, meltTime: 4)
            ],
            surgeBarriers: [
                SurgeBarrier(position: CGPoint(x: 150, y: 150), width: 50, threshold: 0.8)
            ],
            flowBarriers: [
                FlowBarrier(position: CGPoint(x: 350, y: 150), width: 50, threshold: 0.8)
            ],
            resonancePads: [
                ResonancePad(position: CGPoint(x: 250, y: 150), radius: 80)
            ],
            hazards: [],
            tuning: LevelTuning(targetTime: 140, checkpoints: [], hintTriggers: [], mechanicTeaching: MechanicTuning.default)
        )
    }

    static func createHardLevel2() -> LevelDefinition {
        LevelDefinition(
            id: "Level12",
            index: 12,
            title: "Temporal Shift",
            sparkStart: CGPoint(x: 50, y: 250),
            vesperStart: CGPoint(x: 50, y: 50),
            sparkPortal: Portal(position: CGPoint(x: 450, y: 50), radius: 20),
            vesperPortal: Portal(position: CGPoint(x: 450, y: 250), radius: 20),
            windmills: Array(0..<6).map { i in
                Windmill(
                    position: CGPoint(x: 100 + CGFloat(i * 60), y: 150),
                    linkIndex: i + 1,
                    threshold: 0.5
                )
            },
            bridges: Array(0..<6).map { i in
                Bridge(
                    origin: CGPoint(x: 100 + CGFloat(i * 60), y: 100 + CGFloat(i % 2) * 100),
                    maxWidth: 40,
                    linkIndex: i + 1
                )
            },
            heatPlates: [],
            iceWalls: [],
            surgeBarriers: [],
            flowBarriers: [],
            resonancePads: [],
            hazards: [
                Hazard(type: .moving, position: CGPoint(x: 250, y: 150), size: CGSize(width: 300, height: 40))
            ],
            tuning: LevelTuning(targetTime: 150, checkpoints: [], hintTriggers: [], mechanicTeaching: MechanicTuning.default)
        )
    }

    static func createHardLevel3() -> LevelDefinition {
        LevelDefinition(
            id: "Level13",
            index: 13,
            title: "Elemental Chaos",
            sparkStart: CGPoint(x: 250, y: 150),
            vesperStart: CGPoint(x: 250, y: 150),
            sparkPortal: Portal(position: CGPoint(x: 50, y: 50), radius: 20),
            vesperPortal: Portal(position: CGPoint(x: 450, y: 250), radius: 20),
            windmills: [
                Windmill(position: CGPoint(x: 100, y: 100), linkIndex: 1, threshold: 0.7),
                Windmill(position: CGPoint(x: 400, y: 200), linkIndex: 2, threshold: 0.7)
            ],
            bridges: [],
            heatPlates: [
                HeatPlate(position: CGPoint(x: 100, y: 200), radius: 30, linkIndex: 3),
                HeatPlate(position: CGPoint(x: 400, y: 100), radius: 30, linkIndex: 4)
            ],
            iceWalls: [
                // Complex ice wall pattern
                IceWall(position: CGPoint(x: 150, y: 150), size: CGSize(width: 30, height: 200), linkIndex: 3, meltTime: 5),
                IceWall(position: CGPoint(x: 350, y: 150), size: CGSize(width: 30, height: 200), linkIndex: 4, meltTime: 5),
                IceWall(position: CGPoint(x: 250, y: 50), size: CGSize(width: 200, height: 30), linkIndex: 1, meltTime: 3),
                IceWall(position: CGPoint(x: 250, y: 250), size: CGSize(width: 200, height: 30), linkIndex: 2, meltTime: 3)
            ],
            surgeBarriers: [
                SurgeBarrier(position: CGPoint(x: 100, y: 50), width: 80, threshold: 0.9)
            ],
            flowBarriers: [
                FlowBarrier(position: CGPoint(x: 400, y: 250), width: 80, threshold: 0.9)
            ],
            resonancePads: [
                ResonancePad(position: CGPoint(x: 200, y: 100), radius: 40),
                ResonancePad(position: CGPoint(x: 300, y: 200), radius: 40)
            ],
            hazards: [
                Hazard(type: .electric, position: CGPoint(x: 250, y: 150), size: CGSize(width: 50, height: 50))
            ],
            tuning: LevelTuning(targetTime: 180, checkpoints: [], hintTriggers: [], mechanicTeaching: MechanicTuning.default)
        )
    }

    static func createHardLevel4() -> LevelDefinition {
        LevelDefinition(
            id: "Level14",
            index: 14,
            title: "The Gauntlet",
            sparkStart: CGPoint(x: 50, y: 150),
            vesperStart: CGPoint(x: 50, y: 150),
            sparkPortal: Portal(position: CGPoint(x: 450, y: 250), radius: 20),
            vesperPortal: Portal(position: CGPoint(x: 450, y: 50), radius: 20),
            windmills: Array(0..<4).map { i in
                Windmill(
                    position: CGPoint(x: 100 + CGFloat(i * 100), y: 200),
                    linkIndex: i * 2 + 1,
                    threshold: 0.6
                )
            },
            bridges: Array(0..<4).map { i in
                Bridge(
                    origin: CGPoint(x: 100 + CGFloat(i * 100), y: 150),
                    maxWidth: 60,
                    linkIndex: i * 2 + 1
                )
            },
            heatPlates: Array(0..<4).map { i in
                HeatPlate(
                    position: CGPoint(x: 100 + CGFloat(i * 100), y: 100),
                    radius: 25,
                    linkIndex: i * 2 + 2
                )
            },
            iceWalls: Array(0..<4).map { i in
                IceWall(
                    position: CGPoint(x: 100 + CGFloat(i * 100), y: 50),
                    size: CGSize(width: 40, height: 40),
                    linkIndex: i * 2 + 2,
                    meltTime: 2
                )
            },
            surgeBarriers: [
                SurgeBarrier(position: CGPoint(x: 450, y: 200), width: 40, threshold: 0.95)
            ],
            flowBarriers: [
                FlowBarrier(position: CGPoint(x: 450, y: 100), width: 40, threshold: 0.95)
            ],
            resonancePads: [],
            hazards: [
                Hazard(type: .moving, position: CGPoint(x: 250, y: 150), size: CGSize(width: 400, height: 20))
            ],
            tuning: LevelTuning(targetTime: 200, checkpoints: [], hintTriggers: [], mechanicTeaching: MechanicTuning.default)
        )
    }

    static func createHardLevel5() -> LevelDefinition {
        LevelDefinition(
            id: "Level15",
            index: 15,
            title: "Final Convergence",
            sparkStart: CGPoint(x: 50, y: 250),
            vesperStart: CGPoint(x: 450, y: 50),
            sparkPortal: Portal(position: CGPoint(x: 250, y: 150), radius: 15),
            vesperPortal: Portal(position: CGPoint(x: 250, y: 150), radius: 15),
            windmills: [
                // Circular arrangement
                Windmill(position: CGPoint(x: 250, y: 250), linkIndex: 1, threshold: 0.8),
                Windmill(position: CGPoint(x: 350, y: 150), linkIndex: 2, threshold: 0.8),
                Windmill(position: CGPoint(x: 250, y: 50), linkIndex: 3, threshold: 0.8),
                Windmill(position: CGPoint(x: 150, y: 150), linkIndex: 4, threshold: 0.8)
            ],
            bridges: [],
            heatPlates: [
                HeatPlate(position: CGPoint(x: 100, y: 250), radius: 30, linkIndex: 5),
                HeatPlate(position: CGPoint(x: 400, y: 50), radius: 30, linkIndex: 6)
            ],
            iceWalls: [
                // Protective shell around center
                IceWall(position: CGPoint(x: 200, y: 150), size: CGSize(width: 20, height: 100), linkIndex: 5, meltTime: 6),
                IceWall(position: CGPoint(x: 300, y: 150), size: CGSize(width: 20, height: 100), linkIndex: 6, meltTime: 6),
                IceWall(position: CGPoint(x: 250, y: 100), size: CGSize(width: 100, height: 20), linkIndex: 1, meltTime: 4),
                IceWall(position: CGPoint(x: 250, y: 200), size: CGSize(width: 100, height: 20), linkIndex: 2, meltTime: 4)
            ],
            surgeBarriers: [
                SurgeBarrier(position: CGPoint(x: 100, y: 150), width: 100, threshold: 1.0)
            ],
            flowBarriers: [
                FlowBarrier(position: CGPoint(x: 400, y: 150), width: 100, threshold: 1.0)
            ],
            resonancePads: [
                ResonancePad(position: CGPoint(x: 250, y: 150), radius: 100)
            ],
            hazards: [
                Hazard(type: .rotating, position: CGPoint(x: 250, y: 150), size: CGSize(width: 150, height: 150))
            ],
            tuning: LevelTuning(
                targetTime: 240,
                checkpoints: [],
                hintTriggers: [
                    HintTrigger(failCount: 5, timeStuck: 60, hint: "Perfect synchronization required"),
                    HintTrigger(failCount: 10, timeStuck: 120, hint: "Both must reach center simultaneously")
                ],
                mechanicTeaching: MechanicTuning.default
            )
        )
    }
}

// MARK: - Level Definition Models

struct LevelDefinition: Codable {
    let id: String
    let index: Int
    let title: String
    let sparkStart: CGPoint
    let vesperStart: CGPoint
    let sparkPortal: Portal
    let vesperPortal: Portal
    let windmills: [Windmill]
    let bridges: [Bridge]
    let heatPlates: [HeatPlate]
    let iceWalls: [IceWall]
    let surgeBarriers: [SurgeBarrier]
    let flowBarriers: [FlowBarrier]
    let resonancePads: [ResonancePad]
    let hazards: [Hazard]
    let tuning: LevelTuning
}

struct Portal: Codable {
    let position: CGPoint
    let radius: CGFloat
}

struct Windmill: Codable {
    let position: CGPoint
    let linkIndex: Int
    let threshold: CGFloat
}

struct Bridge: Codable {
    let origin: CGPoint
    let maxWidth: CGFloat
    let linkIndex: Int
}

struct HeatPlate: Codable {
    let position: CGPoint
    let radius: CGFloat
    let linkIndex: Int
}

struct IceWall: Codable {
    let position: CGPoint
    let size: CGSize
    let linkIndex: Int
    let meltTime: TimeInterval
}

struct SurgeBarrier: Codable {
    let position: CGPoint
    let width: CGFloat
    let threshold: CGFloat
}

struct FlowBarrier: Codable {
    let position: CGPoint
    let width: CGFloat
    let threshold: CGFloat
}

struct ResonancePad: Codable {
    let position: CGPoint
    let radius: CGFloat
}

struct Hazard: Codable {
    let type: HazardType
    let position: CGPoint
    let size: CGSize

    enum HazardType: String, Codable {
        case void, electric, moving, rotating
    }
}

struct LevelTuning: Codable {
    let targetTime: TimeInterval
    let checkpoints: [CGPoint]
    let hintTriggers: [HintTrigger]
    let mechanicTeaching: MechanicTuning
}

struct HintTrigger: Codable {
    let failCount: Int
    let timeStuck: TimeInterval
    let hint: String
}

struct MechanicTuning: Codable {
    let windPowerThreshold: CGFloat
    let heatMeltRate: CGFloat
    let refreezeRate: CGFloat
    let bridgeExtendSpeed: CGFloat
    let vesperFriction: CGFloat
    let sparkDragRadius: CGFloat
    let proximityGlowThreshold: CGFloat
    let surgeDecayRate: CGFloat
    let flowDecayRate: CGFloat
    let proximityMaxRange: CGFloat

    static let `default` = MechanicTuning(
        windPowerThreshold: 30,
        heatMeltRate: 0.4,
        refreezeRate: 0.12,
        bridgeExtendSpeed: 60,
        vesperFriction: 0.92,
        sparkDragRadius: 60,
        proximityGlowThreshold: 0.75,
        surgeDecayRate: 0.995,
        flowDecayRate: 0.99,
        proximityMaxRange: 150
    )
}