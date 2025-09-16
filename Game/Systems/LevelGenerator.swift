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

        // Expert Levels (16-25)
        for i in 16...25 {
            levels.append(createExpertLevel(index: i))
        }

        // Master Levels (26-35)
        for i in 26...35 {
            levels.append(createMasterLevel(index: i))
        }

        // Extreme Levels (36-45)
        for i in 36...45 {
            levels.append(createExtremeLevel(index: i))
        }

        // Legendary Levels (46-50)
        for i in 46...50 {
            levels.append(createLegendaryLevel(index: i))
        }

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

    // MARK: - Expert Levels (16-25)
    static func createExpertLevel(index: Int) -> LevelDefinition {
        let difficulty = Float(index - 15) / 10.0 // 0.1 to 1.0 for experts

        return LevelDefinition(
            id: "Level\(String(format: "%02d", index))",
            index: index,
            title: expertLevelTitles[index - 16],
            sparkStart: CGPoint(x: 50 + CGFloat(index % 3) * 100, y: 250),
            vesperStart: CGPoint(x: 450 - CGFloat(index % 3) * 100, y: 50),
            sparkPortal: Portal(position: CGPoint(x: 450, y: 200 + CGFloat(index % 2) * 50), radius: 18),
            vesperPortal: Portal(position: CGPoint(x: 50, y: 100 - CGFloat(index % 2) * 50), radius: 18),
            windmills: createExpertWindmills(index: index, difficulty: difficulty),
            bridges: createExpertBridges(index: index, difficulty: difficulty),
            heatPlates: createExpertHeatPlates(index: index, difficulty: difficulty),
            iceWalls: createExpertIceWalls(index: index, difficulty: difficulty),
            surgeBarriers: [
                SurgeBarrier(position: CGPoint(x: 150 + CGFloat(index % 3) * 100, y: 200), width: 60, threshold: 0.7 + CGFloat(difficulty * 0.2))
            ],
            flowBarriers: [
                FlowBarrier(position: CGPoint(x: 350 - CGFloat(index % 3) * 100, y: 100), width: 60, threshold: 0.7 + CGFloat(difficulty * 0.2))
            ],
            resonancePads: [
                ResonancePad(position: CGPoint(x: 250, y: 150), radius: 40 + CGFloat(index % 3) * 20)
            ],
            hazards: createExpertHazards(index: index),
            tuning: LevelTuning(
                targetTime: TimeInterval(150 + index * 10),
                checkpoints: [CGPoint(x: 250, y: 150)],
                hintTriggers: [],
                mechanicTeaching: MechanicTuning.default
            )
        )
    }

    private static func createExpertWindmills(index: Int, difficulty: Float) -> [Windmill] {
        let count = 3 + (index % 3)
        return (0..<count).map { i in
            Windmill(
                position: CGPoint(x: 100 + CGFloat(i * 100), y: 200 + CGFloat(i % 2) * 50),
                linkIndex: i + 1,
                threshold: 0.5 + CGFloat(difficulty * 0.3)
            )
        }
    }

    private static func createExpertBridges(index: Int, difficulty: Float) -> [Bridge] {
        let pattern = index % 4
        switch pattern {
        case 0: // Sequential bridges
            return (0..<3).map { i in
                Bridge(origin: CGPoint(x: 150 + CGFloat(i * 100), y: 150), maxWidth: 70, linkIndex: i + 1)
            }
        case 1: // Parallel bridges
            return [
                Bridge(origin: CGPoint(x: 200, y: 100), maxWidth: 150, linkIndex: 1),
                Bridge(origin: CGPoint(x: 200, y: 200), maxWidth: 150, linkIndex: 2)
            ]
        case 2: // Crossing bridges
            return [
                Bridge(origin: CGPoint(x: 150, y: 120), maxWidth: 200, linkIndex: 1),
                Bridge(origin: CGPoint(x: 350, y: 180), maxWidth: 200, linkIndex: 2)
            ]
        default: // Complex network
            return (0..<4).map { i in
                Bridge(origin: CGPoint(x: 100 + CGFloat(i * 100), y: 100 + CGFloat(i * 30)), maxWidth: 80, linkIndex: i + 1)
            }
        }
    }

    private static func createExpertHeatPlates(index: Int, difficulty: Float) -> [HeatPlate] {
        return (0..<(2 + index % 2)).map { i in
            HeatPlate(
                position: CGPoint(x: 150 + CGFloat(i * 200), y: 50 + CGFloat(i * 200)),
                radius: 30 - CGFloat(difficulty * 5),
                linkIndex: i + 1
            )
        }
    }

    private static func createExpertIceWalls(index: Int, difficulty: Float) -> [IceWall] {
        let pattern = (index - 16) % 3
        switch pattern {
        case 0: // Maze pattern
            return (0..<5).map { i in
                IceWall(
                    position: CGPoint(x: 100 + CGFloat(i * 80), y: 150),
                    size: CGSize(width: 30, height: 100 + CGFloat(i % 2) * 50),
                    linkIndex: (i % 2) + 1,
                    meltTime: 3 + TimeInterval(difficulty * 2)
                )
            }
        case 1: // Barrier pattern
            return [
                IceWall(position: CGPoint(x: 250, y: 80), size: CGSize(width: 300, height: 30), linkIndex: 1, meltTime: 5),
                IceWall(position: CGPoint(x: 250, y: 220), size: CGSize(width: 300, height: 30), linkIndex: 2, meltTime: 5)
            ]
        default: // Complex pattern
            return (0..<6).map { i in
                IceWall(
                    position: CGPoint(x: 80 + CGFloat(i * 70), y: 100 + CGFloat(i % 3) * 50),
                    size: CGSize(width: 40, height: 40),
                    linkIndex: (i % 3) + 1,
                    meltTime: 2 + TimeInterval(i % 2) * 2
                )
            }
        }
    }

    private static func createExpertHazards(index: Int) -> [Hazard] {
        let pattern = index % 3
        switch pattern {
        case 0:
            return [Hazard(type: .moving, position: CGPoint(x: 250, y: 150), size: CGSize(width: 200, height: 30))]
        case 1:
            return [
                Hazard(type: .electric, position: CGPoint(x: 150, y: 150), size: CGSize(width: 60, height: 60)),
                Hazard(type: .electric, position: CGPoint(x: 350, y: 150), size: CGSize(width: 60, height: 60))
            ]
        default:
            return [Hazard(type: .rotating, position: CGPoint(x: 250, y: 150), size: CGSize(width: 180, height: 180))]
        }
    }

    // MARK: - Master Levels (26-35)
    static func createMasterLevel(index: Int) -> LevelDefinition {
        let difficulty = Float(index - 25) / 10.0
        let complexity = index % 4 // Creates 4 different patterns

        return LevelDefinition(
            id: "Level\(String(format: "%02d", index))",
            index: index,
            title: masterLevelTitles[index - 26],
            sparkStart: CGPoint(x: 250, y: 250 - CGFloat(complexity * 50)),
            vesperStart: CGPoint(x: 250, y: 50 + CGFloat(complexity * 50)),
            sparkPortal: Portal(position: masterPortalPositions[complexity].spark, radius: 15),
            vesperPortal: Portal(position: masterPortalPositions[complexity].vesper, radius: 15),
            windmills: createMasterWindmills(complexity: complexity, difficulty: difficulty),
            bridges: createMasterBridges(complexity: complexity),
            heatPlates: createMasterHeatPlates(complexity: complexity),
            iceWalls: createMasterIceWalls(complexity: complexity, difficulty: difficulty),
            surgeBarriers: createMasterSurgeBarriers(complexity: complexity, difficulty: difficulty),
            flowBarriers: createMasterFlowBarriers(complexity: complexity, difficulty: difficulty),
            resonancePads: createMasterResonancePads(complexity: complexity),
            hazards: createMasterHazards(index: index, complexity: complexity),
            tuning: LevelTuning(
                targetTime: TimeInterval(200 + index * 15),
                checkpoints: createMasterCheckpoints(complexity: complexity),
                hintTriggers: [],
                mechanicTeaching: MechanicTuning(
                    windPowerThreshold: 40,
                    heatMeltRate: 0.3,
                    refreezeRate: 0.15,
                    bridgeExtendSpeed: 50,
                    vesperFriction: 0.94,
                    sparkDragRadius: 50,
                    proximityGlowThreshold: 0.8,
                    surgeDecayRate: 0.993,
                    flowDecayRate: 0.985,
                    proximityMaxRange: 120
                )
            )
        )
    }

    private static func createMasterWindmills(complexity: Int, difficulty: Float) -> [Windmill] {
        switch complexity {
        case 0: // Circle pattern
            return (0..<8).map { i in
                let angle = CGFloat(i) * .pi / 4
                Windmill(
                    position: CGPoint(x: 250 + cos(angle) * 150, y: 150 + sin(angle) * 150),
                    linkIndex: i + 1,
                    threshold: 0.6 + CGFloat(difficulty * 0.3)
                )
            }
        case 1: // Grid pattern
            return (0..<9).map { i in
                Windmill(
                    position: CGPoint(x: 150 + CGFloat(i % 3) * 100, y: 50 + CGFloat(i / 3) * 100),
                    linkIndex: i + 1,
                    threshold: 0.7
                )
            }
        case 2: // Diamond pattern
            return [
                Windmill(position: CGPoint(x: 250, y: 50), linkIndex: 1, threshold: 0.8),
                Windmill(position: CGPoint(x: 150, y: 150), linkIndex: 2, threshold: 0.8),
                Windmill(position: CGPoint(x: 350, y: 150), linkIndex: 3, threshold: 0.8),
                Windmill(position: CGPoint(x: 250, y: 250), linkIndex: 4, threshold: 0.8)
            ]
        default: // Spiral pattern
            return (0..<6).map { i in
                let angle = CGFloat(i) * .pi / 3
                let radius = 50 + CGFloat(i * 20)
                return Windmill(
                    position: CGPoint(x: 250 + cos(angle) * radius, y: 150 + sin(angle) * radius),
                    linkIndex: i + 1,
                    threshold: 0.65 + CGFloat(i) * 0.05
                )
            }
        }
    }

    private static func createMasterBridges(complexity: Int) -> [Bridge] {
        switch complexity {
        case 0: // Star pattern
            return (0..<4).map { i in
                let angle = CGFloat(i) * .pi / 2
                Bridge(
                    origin: CGPoint(x: 250 + cos(angle) * 100, y: 150 + sin(angle) * 100),
                    maxWidth: 100,
                    linkIndex: i + 1
                )
            }
        case 1: // Layered bridges
            return (0..<3).map { i in
                Bridge(origin: CGPoint(x: 100, y: 80 + CGFloat(i * 60)), maxWidth: 300, linkIndex: i + 1)
            }
        case 2: // Zigzag pattern
            return (0..<5).map { i in
                Bridge(
                    origin: CGPoint(x: 50 + CGFloat(i * 80), y: 100 + CGFloat(i % 2) * 100),
                    maxWidth: 80,
                    linkIndex: i + 1
                )
            }
        default: // Complex interconnected
            return [
                Bridge(origin: CGPoint(x: 100, y: 100), maxWidth: 150, linkIndex: 1),
                Bridge(origin: CGPoint(x: 250, y: 150), maxWidth: 100, linkIndex: 2),
                Bridge(origin: CGPoint(x: 350, y: 200), maxWidth: 120, linkIndex: 3),
                Bridge(origin: CGPoint(x: 200, y: 250), maxWidth: 140, linkIndex: 4)
            ]
        }
    }

    private static func createMasterHeatPlates(complexity: Int) -> [HeatPlate] {
        switch complexity {
        case 0:
            return [
                HeatPlate(position: CGPoint(x: 100, y: 100), radius: 25, linkIndex: 1),
                HeatPlate(position: CGPoint(x: 400, y: 200), radius: 25, linkIndex: 2)
            ]
        case 1:
            return (0..<4).map { i in
                HeatPlate(
                    position: CGPoint(x: 125 + CGFloat(i * 75), y: 250),
                    radius: 20,
                    linkIndex: i + 1
                )
            }
        case 2:
            return [
                HeatPlate(position: CGPoint(x: 250, y: 150), radius: 40, linkIndex: 1),
                HeatPlate(position: CGPoint(x: 150, y: 250), radius: 30, linkIndex: 2),
                HeatPlate(position: CGPoint(x: 350, y: 50), radius: 30, linkIndex: 3)
            ]
        default:
            return (0..<3).map { i in
                let angle = CGFloat(i) * 2 * .pi / 3
                return HeatPlate(
                    position: CGPoint(x: 250 + cos(angle) * 120, y: 150 + sin(angle) * 120),
                    radius: 25,
                    linkIndex: i + 1
                )
            }
        }
    }

    private static func createMasterIceWalls(complexity: Int, difficulty: Float) -> [IceWall] {
        let baseTime = 4.0 + Double(difficulty * 3)

        switch complexity {
        case 0: // Fortress pattern
            return [
                // Outer walls
                IceWall(position: CGPoint(x: 100, y: 150), size: CGSize(width: 30, height: 200), linkIndex: 1, meltTime: baseTime),
                IceWall(position: CGPoint(x: 400, y: 150), size: CGSize(width: 30, height: 200), linkIndex: 2, meltTime: baseTime),
                IceWall(position: CGPoint(x: 250, y: 50), size: CGSize(width: 200, height: 30), linkIndex: 3, meltTime: baseTime),
                IceWall(position: CGPoint(x: 250, y: 250), size: CGSize(width: 200, height: 30), linkIndex: 4, meltTime: baseTime),
                // Inner walls
                IceWall(position: CGPoint(x: 200, y: 150), size: CGSize(width: 20, height: 100), linkIndex: 1, meltTime: baseTime * 0.7),
                IceWall(position: CGPoint(x: 300, y: 150), size: CGSize(width: 20, height: 100), linkIndex: 2, meltTime: baseTime * 0.7)
            ]
        case 1: // Checkerboard pattern
            var walls: [IceWall] = []
            for i in 0..<4 {
                for j in 0..<4 {
                    if (i + j) % 2 == 0 {
                        walls.append(IceWall(
                            position: CGPoint(x: 100 + CGFloat(i * 100), y: 50 + CGFloat(j * 60)),
                            size: CGSize(width: 60, height: 40),
                            linkIndex: ((i + j) / 2) % 3 + 1,
                            meltTime: baseTime * (0.5 + Double(i + j) * 0.1)
                        ))
                    }
                }
            }
            return walls
        case 2: // Spiral walls
            return (0..<8).map { i in
                let angle = CGFloat(i) * .pi / 4
                let radius = 80 + CGFloat(i * 10)
                return IceWall(
                    position: CGPoint(x: 250 + cos(angle) * radius, y: 150 + sin(angle) * radius),
                    size: CGSize(width: 40, height: 60),
                    linkIndex: (i % 4) + 1,
                    meltTime: baseTime * (0.6 + Double(i) * 0.1)
                )
            }
        default: // Labyrinth pattern
            return [
                IceWall(position: CGPoint(x: 150, y: 100), size: CGSize(width: 100, height: 20), linkIndex: 1, meltTime: baseTime),
                IceWall(position: CGPoint(x: 350, y: 100), size: CGSize(width: 100, height: 20), linkIndex: 2, meltTime: baseTime),
                IceWall(position: CGPoint(x: 150, y: 200), size: CGSize(width: 100, height: 20), linkIndex: 3, meltTime: baseTime),
                IceWall(position: CGPoint(x: 350, y: 200), size: CGSize(width: 100, height: 20), linkIndex: 4, meltTime: baseTime),
                IceWall(position: CGPoint(x: 250, y: 150), size: CGSize(width: 20, height: 100), linkIndex: 1, meltTime: baseTime * 1.5)
            ]
        }
    }

    private static func createMasterSurgeBarriers(complexity: Int, difficulty: Float) -> [SurgeBarrier] {
        let threshold = 0.8 + CGFloat(difficulty * 0.15)

        switch complexity {
        case 0:
            return [SurgeBarrier(position: CGPoint(x: 250, y: 200), width: 200, threshold: threshold)]
        case 1:
            return [
                SurgeBarrier(position: CGPoint(x: 150, y: 180), width: 80, threshold: threshold),
                SurgeBarrier(position: CGPoint(x: 350, y: 180), width: 80, threshold: threshold)
            ]
        case 2:
            return (0..<3).map { i in
                SurgeBarrier(position: CGPoint(x: 150 + CGFloat(i * 100), y: 220), width: 60, threshold: threshold - CGFloat(i) * 0.05)
            }
        default:
            return [
                SurgeBarrier(position: CGPoint(x: 100, y: 250), width: 50, threshold: threshold),
                SurgeBarrier(position: CGPoint(x: 250, y: 250), width: 100, threshold: threshold * 0.9),
                SurgeBarrier(position: CGPoint(x: 400, y: 250), width: 50, threshold: threshold)
            ]
        }
    }

    private static func createMasterFlowBarriers(complexity: Int, difficulty: Float) -> [FlowBarrier] {
        let threshold = 0.8 + CGFloat(difficulty * 0.15)

        switch complexity {
        case 0:
            return [FlowBarrier(position: CGPoint(x: 250, y: 100), width: 200, threshold: threshold)]
        case 1:
            return [
                FlowBarrier(position: CGPoint(x: 150, y: 80), width: 80, threshold: threshold),
                FlowBarrier(position: CGPoint(x: 350, y: 80), width: 80, threshold: threshold)
            ]
        case 2:
            return (0..<3).map { i in
                FlowBarrier(position: CGPoint(x: 150 + CGFloat(i * 100), y: 50), width: 60, threshold: threshold - CGFloat(i) * 0.05)
            }
        default:
            return [
                FlowBarrier(position: CGPoint(x: 100, y: 50), width: 50, threshold: threshold),
                FlowBarrier(position: CGPoint(x: 250, y: 50), width: 100, threshold: threshold * 0.9),
                FlowBarrier(position: CGPoint(x: 400, y: 50), width: 50, threshold: threshold)
            ]
        }
    }

    private static func createMasterResonancePads(complexity: Int) -> [ResonancePad] {
        switch complexity {
        case 0:
            return [ResonancePad(position: CGPoint(x: 250, y: 150), radius: 100)]
        case 1:
            return [
                ResonancePad(position: CGPoint(x: 150, y: 150), radius: 60),
                ResonancePad(position: CGPoint(x: 350, y: 150), radius: 60)
            ]
        case 2:
            return (0..<3).map { i in
                ResonancePad(position: CGPoint(x: 150 + CGFloat(i * 100), y: 150), radius: 40)
            }
        default:
            return [
                ResonancePad(position: CGPoint(x: 250, y: 150), radius: 50),
                ResonancePad(position: CGPoint(x: 150, y: 50), radius: 30),
                ResonancePad(position: CGPoint(x: 350, y: 250), radius: 30)
            ]
        }
    }

    private static func createMasterHazards(index: Int, complexity: Int) -> [Hazard] {
        switch complexity {
        case 0:
            return [
                Hazard(type: .rotating, position: CGPoint(x: 250, y: 150), size: CGSize(width: 200, height: 200)),
                Hazard(type: .void, position: CGPoint(x: 100, y: 50), size: CGSize(width: 50, height: 50)),
                Hazard(type: .void, position: CGPoint(x: 400, y: 250), size: CGSize(width: 50, height: 50))
            ]
        case 1:
            return [
                Hazard(type: .moving, position: CGPoint(x: 250, y: 100), size: CGSize(width: 300, height: 20)),
                Hazard(type: .moving, position: CGPoint(x: 250, y: 200), size: CGSize(width: 300, height: 20))
            ]
        case 2:
            return (0..<4).map { i in
                Hazard(type: .electric, position: CGPoint(x: 100 + CGFloat(i * 100), y: 150), size: CGSize(width: 40, height: 40))
            }
        default:
            return [
                Hazard(type: .rotating, position: CGPoint(x: 150, y: 150), size: CGSize(width: 100, height: 100)),
                Hazard(type: .rotating, position: CGPoint(x: 350, y: 150), size: CGSize(width: 100, height: 100)),
                Hazard(type: .electric, position: CGPoint(x: 250, y: 150), size: CGSize(width: 60, height: 200))
            ]
        }
    }

    private static func createMasterCheckpoints(complexity: Int) -> [CGPoint] {
        switch complexity {
        case 0:
            return [CGPoint(x: 250, y: 150)]
        case 1:
            return [CGPoint(x: 150, y: 150), CGPoint(x: 350, y: 150)]
        case 2:
            return [CGPoint(x: 200, y: 100), CGPoint(x: 300, y: 200)]
        default:
            return [CGPoint(x: 250, y: 50), CGPoint(x: 250, y: 150), CGPoint(x: 250, y: 250)]
        }
    }

    // MARK: - Extreme Levels (36-45)
    static func createExtremeLevel(index: Int) -> LevelDefinition {
        let variant = (index - 36) % 5

        return LevelDefinition(
            id: "Level\(String(format: "%02d", index))",
            index: index,
            title: extremeLevelTitles[index - 36],
            sparkStart: extremeStartPositions[variant].spark,
            vesperStart: extremeStartPositions[variant].vesper,
            sparkPortal: Portal(position: extremePortalPositions[variant].spark, radius: 12),
            vesperPortal: Portal(position: extremePortalPositions[variant].vesper, radius: 12),
            windmills: createExtremeWindmills(variant: variant),
            bridges: createExtremeBridges(variant: variant),
            heatPlates: createExtremeHeatPlates(variant: variant),
            iceWalls: createExtremeIceWalls(variant: variant),
            surgeBarriers: createExtremeSurgeBarriers(variant: variant),
            flowBarriers: createExtremeFlowBarriers(variant: variant),
            resonancePads: createExtremeResonancePads(variant: variant),
            hazards: createExtremeHazards(variant: variant),
            tuning: LevelTuning(
                targetTime: TimeInterval(300 + index * 20),
                checkpoints: createExtremeCheckpoints(variant: variant),
                hintTriggers: [],
                mechanicTeaching: MechanicTuning(
                    windPowerThreshold: 50,
                    heatMeltRate: 0.25,
                    refreezeRate: 0.2,
                    bridgeExtendSpeed: 40,
                    vesperFriction: 0.95,
                    sparkDragRadius: 40,
                    proximityGlowThreshold: 0.85,
                    surgeDecayRate: 0.99,
                    flowDecayRate: 0.98,
                    proximityMaxRange: 100
                )
            )
        )
    }

    private static func createExtremeWindmills(variant: Int) -> [Windmill] {
        switch variant {
        case 0: // Double helix pattern
            return (0..<10).map { i in
                let t = CGFloat(i) / 10.0
                let x1 = 150 + cos(t * 4 * .pi) * 50
                let x2 = 350 - cos(t * 4 * .pi) * 50
                let y = 50 + CGFloat(i * 25)
                return [
                    Windmill(position: CGPoint(x: x1, y: y), linkIndex: i * 2 + 1, threshold: 0.85),
                    Windmill(position: CGPoint(x: x2, y: y), linkIndex: i * 2 + 2, threshold: 0.85)
                ]
            }.flatMap { $0 }

        case 1: // Concentric circles
            var windmills: [Windmill] = []
            for ring in 0..<3 {
                let radius = 60 + CGFloat(ring * 60)
                let count = 4 + ring * 2
                for i in 0..<count {
                    let angle = CGFloat(i) * 2 * .pi / CGFloat(count)
                    windmills.append(Windmill(
                        position: CGPoint(x: 250 + cos(angle) * radius, y: 150 + sin(angle) * radius),
                        linkIndex: ring * 10 + i + 1,
                        threshold: 0.8 + CGFloat(ring) * 0.05
                    ))
                }
            }
            return windmills

        case 2: // Wave pattern
            return (0..<12).map { i in
                let x = 50 + CGFloat(i * 35)
                let y = 150 + sin(CGFloat(i) * .pi / 3) * 80
                return Windmill(position: CGPoint(x: x, y: y), linkIndex: i + 1, threshold: 0.9)
            }

        case 3: // Fractal pattern
            var windmills: [Windmill] = []
            // Center
            windmills.append(Windmill(position: CGPoint(x: 250, y: 150), linkIndex: 1, threshold: 1.0))
            // First layer
            for i in 0..<4 {
                let angle = CGFloat(i) * .pi / 2
                windmills.append(Windmill(
                    position: CGPoint(x: 250 + cos(angle) * 100, y: 150 + sin(angle) * 100),
                    linkIndex: i + 2,
                    threshold: 0.9
                ))
            }
            // Second layer
            for i in 0..<8 {
                let angle = CGFloat(i) * .pi / 4
                windmills.append(Windmill(
                    position: CGPoint(x: 250 + cos(angle) * 170, y: 150 + sin(angle) * 170),
                    linkIndex: i + 6,
                    threshold: 0.85
                ))
            }
            return windmills

        default: // Chaotic pattern
            return (0..<15).map { i in
                let x = 50 + CGFloat.random(in: 0...400)
                let y = 50 + CGFloat.random(in: 0...200)
                return Windmill(position: CGPoint(x: x, y: y), linkIndex: i + 1, threshold: 0.7 + CGFloat.random(in: 0...0.3))
            }
        }
    }

    private static func createExtremeBridges(variant: Int) -> [Bridge] {
        switch variant {
        case 0: // Interlocking bridges
            return (0..<6).map { i in
                Bridge(
                    origin: CGPoint(x: 50 + CGFloat(i * 70), y: 100 + CGFloat(i % 2) * 100),
                    maxWidth: 120,
                    linkIndex: i + 1
                )
            }
        case 1: // Radial bridges
            return (0..<8).map { i in
                let angle = CGFloat(i) * .pi / 4
                return Bridge(
                    origin: CGPoint(x: 250, y: 150),
                    maxWidth: 150,
                    linkIndex: i + 1
                )
            }
        case 2: // Cascade bridges
            return (0..<5).map { i in
                Bridge(
                    origin: CGPoint(x: 100 + CGFloat(i * 20), y: 50 + CGFloat(i * 40)),
                    maxWidth: 200 - CGFloat(i * 20),
                    linkIndex: i + 1
                )
            }
        case 3: // Network bridges
            var bridges: [Bridge] = []
            for i in 0..<3 {
                for j in 0..<3 {
                    bridges.append(Bridge(
                        origin: CGPoint(x: 100 + CGFloat(i * 150), y: 50 + CGFloat(j * 100)),
                        maxWidth: 100,
                        linkIndex: i * 3 + j + 1
                    ))
                }
            }
            return bridges
        default: // Dynamic bridges
            return (0..<7).map { i in
                Bridge(
                    origin: CGPoint(x: 50 + CGFloat(i * 60), y: 150),
                    maxWidth: 40 + CGFloat(i * 10),
                    linkIndex: i + 1
                )
            }
        }
    }

    private static func createExtremeHeatPlates(variant: Int) -> [HeatPlate] {
        switch variant {
        case 0:
            return (0..<5).map { i in
                HeatPlate(position: CGPoint(x: 100 + CGFloat(i * 80), y: 250), radius: 20, linkIndex: i + 1)
            }
        case 1:
            return [
                HeatPlate(position: CGPoint(x: 250, y: 150), radius: 50, linkIndex: 1),
                HeatPlate(position: CGPoint(x: 150, y: 50), radius: 30, linkIndex: 2),
                HeatPlate(position: CGPoint(x: 350, y: 250), radius: 30, linkIndex: 3),
                HeatPlate(position: CGPoint(x: 150, y: 250), radius: 25, linkIndex: 4),
                HeatPlate(position: CGPoint(x: 350, y: 50), radius: 25, linkIndex: 5)
            ]
        case 2:
            return (0..<6).map { i in
                let angle = CGFloat(i) * .pi / 3
                return HeatPlate(
                    position: CGPoint(x: 250 + cos(angle) * 140, y: 150 + sin(angle) * 140),
                    radius: 22,
                    linkIndex: i + 1
                )
            }
        case 3:
            var plates: [HeatPlate] = []
            for i in 0..<2 {
                for j in 0..<3 {
                    plates.append(HeatPlate(
                        position: CGPoint(x: 150 + CGFloat(i * 200), y: 50 + CGFloat(j * 100)),
                        radius: 25,
                        linkIndex: i * 3 + j + 1
                    ))
                }
            }
            return plates
        default:
            return (0..<4).map { i in
                HeatPlate(
                    position: CGPoint(x: 125 + CGFloat(i * 75), y: 150 + sin(CGFloat(i) * .pi / 2) * 80),
                    radius: 28,
                    linkIndex: i + 1
                )
            }
        }
    }

    private static func createExtremeIceWalls(variant: Int) -> [IceWall] {
        switch variant {
        case 0: // Fortress within fortress
            var walls: [IceWall] = []
            // Outer fortress
            for i in 0..<4 {
                let positions = [
                    CGPoint(x: 50, y: 150), CGPoint(x: 450, y: 150),
                    CGPoint(x: 250, y: 30), CGPoint(x: 250, y: 270)
                ]
                let sizes = [
                    CGSize(width: 20, height: 240), CGSize(width: 20, height: 240),
                    CGSize(width: 400, height: 20), CGSize(width: 400, height: 20)
                ]
                walls.append(IceWall(position: positions[i], size: sizes[i], linkIndex: i + 1, meltTime: 8))
            }
            // Inner fortress
            for i in 0..<4 {
                let positions = [
                    CGPoint(x: 150, y: 150), CGPoint(x: 350, y: 150),
                    CGPoint(x: 250, y: 100), CGPoint(x: 250, y: 200)
                ]
                let sizes = [
                    CGSize(width: 15, height: 100), CGSize(width: 15, height: 100),
                    CGSize(width: 200, height: 15), CGSize(width: 200, height: 15)
                ]
                walls.append(IceWall(position: positions[i], size: sizes[i], linkIndex: (i % 2) + 5, meltTime: 6))
            }
            return walls

        case 1: // Ice maze
            var walls: [IceWall] = []
            // Horizontal walls
            for i in 0..<5 {
                walls.append(IceWall(
                    position: CGPoint(x: 100 + CGFloat(i % 2) * 200, y: 50 + CGFloat(i * 50)),
                    size: CGSize(width: 150, height: 20),
                    linkIndex: (i % 3) + 1,
                    meltTime: 5 + Double(i % 2) * 2
                ))
            }
            // Vertical walls
            for i in 0..<4 {
                walls.append(IceWall(
                    position: CGPoint(x: 100 + CGFloat(i * 100), y: 150),
                    size: CGSize(width: 20, height: 150),
                    linkIndex: (i % 3) + 4,
                    meltTime: 4 + Double(i % 2) * 3
                ))
            }
            return walls

        case 2: // Diamond ice pattern
            let centers = [
                CGPoint(x: 150, y: 150), CGPoint(x: 350, y: 150),
                CGPoint(x: 250, y: 50), CGPoint(x: 250, y: 250)
            ]
            return centers.enumerated().flatMap { index, center in
                return (0..<4).map { i in
                    let angle = CGFloat(i) * .pi / 2
                    return IceWall(
                        position: CGPoint(x: center.x + cos(angle) * 40, y: center.y + sin(angle) * 40),
                        size: CGSize(width: 30, height: 30),
                        linkIndex: (index % 3) + 1,
                        meltTime: 4 + Double(index) * 0.5
                    )
                }
            }

        case 3: // Layered ice barriers
            return (0..<4).map { layer in
                IceWall(
                    position: CGPoint(x: 250, y: 50 + CGFloat(layer * 60)),
                    size: CGSize(width: 300 - CGFloat(layer * 50), height: 25),
                    linkIndex: layer + 1,
                    meltTime: 7 - Double(layer)
                )
            }

        default: // Complex ice lattice
            var walls: [IceWall] = []
            for i in 0..<3 {
                for j in 0..<3 {
                    if i != 1 || j != 1 { // Leave center open
                        walls.append(IceWall(
                            position: CGPoint(x: 150 + CGFloat(i * 100), y: 50 + CGFloat(j * 100)),
                            size: CGSize(width: 60, height: 60),
                            linkIndex: ((i + j) % 4) + 1,
                            meltTime: 3 + Double(i + j)
                        ))
                    }
                }
            }
            return walls
        }
    }

    private static func createExtremeSurgeBarriers(variant: Int) -> [SurgeBarrier] {
        switch variant {
        case 0:
            return [
                SurgeBarrier(position: CGPoint(x: 100, y: 200), width: 50, threshold: 1.0),
                SurgeBarrier(position: CGPoint(x: 250, y: 200), width: 100, threshold: 0.95),
                SurgeBarrier(position: CGPoint(x: 400, y: 200), width: 50, threshold: 1.0)
            ]
        case 1:
            return (0..<4).map { i in
                SurgeBarrier(
                    position: CGPoint(x: 125 + CGFloat(i * 75), y: 250),
                    width: 60,
                    threshold: 0.9 + CGFloat(i) * 0.025
                )
            }
        case 2:
            return [
                SurgeBarrier(position: CGPoint(x: 250, y: 180), width: 300, threshold: 0.85),
                SurgeBarrier(position: CGPoint(x: 250, y: 220), width: 200, threshold: 0.95)
            ]
        case 3:
            return (0..<5).map { i in
                SurgeBarrier(
                    position: CGPoint(x: 100 + CGFloat(i * 80), y: 200 + CGFloat(i % 2) * 40),
                    width: 40,
                    threshold: 1.0 - CGFloat(i) * 0.02
                )
            }
        default:
            return [
                SurgeBarrier(position: CGPoint(x: 150, y: 250), width: 100, threshold: 0.92),
                SurgeBarrier(position: CGPoint(x: 350, y: 250), width: 100, threshold: 0.92),
                SurgeBarrier(position: CGPoint(x: 250, y: 200), width: 80, threshold: 1.0)
            ]
        }
    }

    private static func createExtremeFlowBarriers(variant: Int) -> [FlowBarrier] {
        switch variant {
        case 0:
            return [
                FlowBarrier(position: CGPoint(x: 100, y: 100), width: 50, threshold: 1.0),
                FlowBarrier(position: CGPoint(x: 250, y: 100), width: 100, threshold: 0.95),
                FlowBarrier(position: CGPoint(x: 400, y: 100), width: 50, threshold: 1.0)
            ]
        case 1:
            return (0..<4).map { i in
                FlowBarrier(
                    position: CGPoint(x: 125 + CGFloat(i * 75), y: 50),
                    width: 60,
                    threshold: 0.9 + CGFloat(i) * 0.025
                )
            }
        case 2:
            return [
                FlowBarrier(position: CGPoint(x: 250, y: 80), width: 300, threshold: 0.85),
                FlowBarrier(position: CGPoint(x: 250, y: 120), width: 200, threshold: 0.95)
            ]
        case 3:
            return (0..<5).map { i in
                FlowBarrier(
                    position: CGPoint(x: 100 + CGFloat(i * 80), y: 100 - CGFloat(i % 2) * 40),
                    width: 40,
                    threshold: 1.0 - CGFloat(i) * 0.02
                )
            }
        default:
            return [
                FlowBarrier(position: CGPoint(x: 150, y: 50), width: 100, threshold: 0.92),
                FlowBarrier(position: CGPoint(x: 350, y: 50), width: 100, threshold: 0.92),
                FlowBarrier(position: CGPoint(x: 250, y: 100), width: 80, threshold: 1.0)
            ]
        }
    }

    private static func createExtremeResonancePads(variant: Int) -> [ResonancePad] {
        switch variant {
        case 0:
            return [
                ResonancePad(position: CGPoint(x: 250, y: 150), radius: 120),
                ResonancePad(position: CGPoint(x: 100, y: 150), radius: 40),
                ResonancePad(position: CGPoint(x: 400, y: 150), radius: 40)
            ]
        case 1:
            return (0..<5).map { i in
                let angle = CGFloat(i) * 2 * .pi / 5
                return ResonancePad(
                    position: CGPoint(x: 250 + cos(angle) * 100, y: 150 + sin(angle) * 100),
                    radius: 35
                )
            }
        case 2:
            return [
                ResonancePad(position: CGPoint(x: 150, y: 150), radius: 80),
                ResonancePad(position: CGPoint(x: 350, y: 150), radius: 80),
                ResonancePad(position: CGPoint(x: 250, y: 50), radius: 50),
                ResonancePad(position: CGPoint(x: 250, y: 250), radius: 50)
            ]
        case 3:
            var pads: [ResonancePad] = []
            for i in 0..<3 {
                for j in 0..<3 {
                    pads.append(ResonancePad(
                        position: CGPoint(x: 150 + CGFloat(i * 100), y: 50 + CGFloat(j * 100)),
                        radius: 30
                    ))
                }
            }
            return pads
        default:
            return [
                ResonancePad(position: CGPoint(x: 250, y: 150), radius: 150),
                ResonancePad(position: CGPoint(x: 50, y: 50), radius: 30),
                ResonancePad(position: CGPoint(x: 450, y: 250), radius: 30)
            ]
        }
    }

    private static func createExtremeHazards(variant: Int) -> [Hazard] {
        switch variant {
        case 0: // Multiple rotating hazards
            return [
                Hazard(type: .rotating, position: CGPoint(x: 150, y: 150), size: CGSize(width: 120, height: 120)),
                Hazard(type: .rotating, position: CGPoint(x: 350, y: 150), size: CGSize(width: 120, height: 120)),
                Hazard(type: .electric, position: CGPoint(x: 250, y: 50), size: CGSize(width: 200, height: 30)),
                Hazard(type: .electric, position: CGPoint(x: 250, y: 250), size: CGSize(width: 200, height: 30))
            ]
        case 1: // Moving hazard maze
            return (0..<6).map { i in
                Hazard(
                    type: .moving,
                    position: CGPoint(x: 250, y: 50 + CGFloat(i * 40)),
                    size: CGSize(width: 350, height: 20)
                )
            }
        case 2: // Electric field
            return (0..<8).map { i in
                let angle = CGFloat(i) * .pi / 4
                return Hazard(
                    type: .electric,
                    position: CGPoint(x: 250 + cos(angle) * 120, y: 150 + sin(angle) * 120),
                    size: CGSize(width: 50, height: 50)
                )
            }
        case 3: // Void zones
            return [
                Hazard(type: .void, position: CGPoint(x: 100, y: 100), size: CGSize(width: 80, height: 80)),
                Hazard(type: .void, position: CGPoint(x: 400, y: 100), size: CGSize(width: 80, height: 80)),
                Hazard(type: .void, position: CGPoint(x: 100, y: 200), size: CGSize(width: 80, height: 80)),
                Hazard(type: .void, position: CGPoint(x: 400, y: 200), size: CGSize(width: 80, height: 80)),
                Hazard(type: .rotating, position: CGPoint(x: 250, y: 150), size: CGSize(width: 100, height: 100))
            ]
        default: // Mixed chaos
            return [
                Hazard(type: .rotating, position: CGPoint(x: 250, y: 150), size: CGSize(width: 250, height: 250)),
                Hazard(type: .moving, position: CGPoint(x: 100, y: 150), size: CGSize(width: 50, height: 200)),
                Hazard(type: .moving, position: CGPoint(x: 400, y: 150), size: CGSize(width: 50, height: 200)),
                Hazard(type: .electric, position: CGPoint(x: 250, y: 50), size: CGSize(width: 60, height: 60)),
                Hazard(type: .electric, position: CGPoint(x: 250, y: 250), size: CGSize(width: 60, height: 60))
            ]
        }
    }

    private static func createExtremeCheckpoints(variant: Int) -> [CGPoint] {
        switch variant {
        case 0:
            return [CGPoint(x: 150, y: 150), CGPoint(x: 350, y: 150)]
        case 1:
            return (0..<4).map { i in
                CGPoint(x: 125 + CGFloat(i * 75), y: 150)
            }
        case 2:
            return [CGPoint(x: 250, y: 50), CGPoint(x: 250, y: 150), CGPoint(x: 250, y: 250)]
        case 3:
            return [
                CGPoint(x: 100, y: 100), CGPoint(x: 400, y: 100),
                CGPoint(x: 100, y: 200), CGPoint(x: 400, y: 200)
            ]
        default:
            return [CGPoint(x: 250, y: 150)]
        }
    }

    // MARK: - Legendary Levels (46-50)
    static func createLegendaryLevel(index: Int) -> LevelDefinition {
        let legendIndex = index - 46

        return LevelDefinition(
            id: "Level\(String(format: "%02d", index))",
            index: index,
            title: legendaryLevelTitles[legendIndex],
            sparkStart: legendaryConfigs[legendIndex].sparkStart,
            vesperStart: legendaryConfigs[legendIndex].vesperStart,
            sparkPortal: Portal(position: legendaryConfigs[legendIndex].sparkPortal, radius: 10),
            vesperPortal: Portal(position: legendaryConfigs[legendIndex].vesperPortal, radius: 10),
            windmills: createLegendaryWindmills(legendIndex: legendIndex),
            bridges: createLegendaryBridges(legendIndex: legendIndex),
            heatPlates: createLegendaryHeatPlates(legendIndex: legendIndex),
            iceWalls: createLegendaryIceWalls(legendIndex: legendIndex),
            surgeBarriers: createLegendarySurgeBarriers(legendIndex: legendIndex),
            flowBarriers: createLegendaryFlowBarriers(legendIndex: legendIndex),
            resonancePads: createLegendaryResonancePads(legendIndex: legendIndex),
            hazards: createLegendaryHazards(legendIndex: legendIndex),
            tuning: LevelTuning(
                targetTime: TimeInterval(400 + index * 30),
                checkpoints: createLegendaryCheckpoints(legendIndex: legendIndex),
                hintTriggers: [
                    HintTrigger(failCount: 10, timeStuck: 120, hint: "Perfect synchronization is the key"),
                    HintTrigger(failCount: 20, timeStuck: 240, hint: "Think outside conventional patterns")
                ],
                mechanicTeaching: MechanicTuning(
                    windPowerThreshold: 60,
                    heatMeltRate: 0.2,
                    refreezeRate: 0.25,
                    bridgeExtendSpeed: 30,
                    vesperFriction: 0.96,
                    sparkDragRadius: 35,
                    proximityGlowThreshold: 0.9,
                    surgeDecayRate: 0.985,
                    flowDecayRate: 0.975,
                    proximityMaxRange: 80
                )
            )
        )
    }

    private static func createLegendaryWindmills(legendIndex: Int) -> [Windmill] {
        switch legendIndex {
        case 0: // "The Infinite Loop"
            var windmills: [Windmill] = []
            // Create figure-8 pattern
            for i in 0..<16 {
                let t = CGFloat(i) / 16.0 * 2 * .pi
                let x = 250 + sin(t) * 150
                let y = 150 + sin(2 * t) * 70
                windmills.append(Windmill(position: CGPoint(x: x, y: y), linkIndex: i + 1, threshold: 0.95))
            }
            return windmills

        case 1: // "Quantum Entanglement"
            // Paired windmills that must be activated simultaneously
            return [
                Windmill(position: CGPoint(x: 100, y: 100), linkIndex: 1, threshold: 1.0),
                Windmill(position: CGPoint(x: 400, y: 200), linkIndex: 1, threshold: 1.0),
                Windmill(position: CGPoint(x: 100, y: 200), linkIndex: 2, threshold: 1.0),
                Windmill(position: CGPoint(x: 400, y: 100), linkIndex: 2, threshold: 1.0),
                Windmill(position: CGPoint(x: 250, y: 150), linkIndex: 3, threshold: 1.0),
                Windmill(position: CGPoint(x: 150, y: 150), linkIndex: 3, threshold: 1.0),
                Windmill(position: CGPoint(x: 350, y: 150), linkIndex: 3, threshold: 1.0)
            ]

        case 2: // "The Singularity"
            // All windmills spiral into center
            return (0..<20).map { i in
                let angle = CGFloat(i) * .pi / 5
                let radius = 200 - CGFloat(i * 8)
                return Windmill(
                    position: CGPoint(x: 250 + cos(angle) * radius, y: 150 + sin(angle) * radius),
                    linkIndex: i + 1,
                    threshold: 0.8 + CGFloat(i) * 0.01
                )
            }

        case 3: // "Dimensional Rift"
            // Windmills in parallel dimensions (alternating patterns)
            var windmills: [Windmill] = []
            for layer in 0..<3 {
                for i in 0..<6 {
                    let angle = CGFloat(i) * .pi / 3 + CGFloat(layer) * .pi / 6
                    let radius = 80 + CGFloat(layer * 40)
                    windmills.append(Windmill(
                        position: CGPoint(x: 250 + cos(angle) * radius, y: 150 + sin(angle) * radius),
                        linkIndex: layer * 6 + i + 1,
                        threshold: 0.9 + CGFloat(layer) * 0.03
                    ))
                }
            }
            return windmills

        case 4: // "The Final Convergence"
            // Ultimate challenge - all mechanics at maximum
            var windmills: [Windmill] = []
            // Corners
            windmills.append(contentsOf: [
                Windmill(position: CGPoint(x: 50, y: 50), linkIndex: 1, threshold: 1.0),
                Windmill(position: CGPoint(x: 450, y: 50), linkIndex: 2, threshold: 1.0),
                Windmill(position: CGPoint(x: 50, y: 250), linkIndex: 3, threshold: 1.0),
                Windmill(position: CGPoint(x: 450, y: 250), linkIndex: 4, threshold: 1.0)
            ])
            // Center ring
            for i in 0..<8 {
                let angle = CGFloat(i) * .pi / 4
                windmills.append(Windmill(
                    position: CGPoint(x: 250 + cos(angle) * 100, y: 150 + sin(angle) * 100),
                    linkIndex: i + 5,
                    threshold: 0.95
                ))
            }
            // Random chaos
            for i in 0..<5 {
                windmills.append(Windmill(
                    position: CGPoint(x: CGFloat.random(in: 100...400), y: CGFloat.random(in: 50...250)),
                    linkIndex: i + 13,
                    threshold: CGFloat.random(in: 0.8...1.0)
                ))
            }
            return windmills

        default:
            return []
        }
    }

    private static func createLegendaryBridges(legendIndex: Int) -> [Bridge] {
        switch legendIndex {
        case 0: // Morphing bridges
            return (0..<8).map { i in
                Bridge(
                    origin: CGPoint(x: 50 + CGFloat(i * 50), y: 150 + sin(CGFloat(i) * .pi / 4) * 50),
                    maxWidth: 60 + CGFloat(i % 3) * 20,
                    linkIndex: i + 1
                )
            }
        case 1: // Quantum bridges
            return [
                Bridge(origin: CGPoint(x: 100, y: 150), maxWidth: 300, linkIndex: 1),
                Bridge(origin: CGPoint(x: 400, y: 150), maxWidth: 300, linkIndex: 1), // Same link!
                Bridge(origin: CGPoint(x: 250, y: 50), maxWidth: 200, linkIndex: 2),
                Bridge(origin: CGPoint(x: 250, y: 250), maxWidth: 200, linkIndex: 2)
            ]
        case 2: // Collapsing bridges
            return (0..<10).map { i in
                Bridge(
                    origin: CGPoint(x: 50 + CGFloat(i * 40), y: 100 + CGFloat(i % 2) * 100),
                    maxWidth: 100 - CGFloat(i * 5),
                    linkIndex: i + 1
                )
            }
        case 3: // Dimensional bridges
            return [
                // X-axis bridges
                Bridge(origin: CGPoint(x: 0, y: 100), maxWidth: 500, linkIndex: 1),
                Bridge(origin: CGPoint(x: 0, y: 200), maxWidth: 500, linkIndex: 2),
                // Y-axis bridges
                Bridge(origin: CGPoint(x: 200, y: 0), maxWidth: 300, linkIndex: 3),
                Bridge(origin: CGPoint(x: 300, y: 0), maxWidth: 300, linkIndex: 4),
                // Diagonal bridges
                Bridge(origin: CGPoint(x: 100, y: 100), maxWidth: 200, linkIndex: 5),
                Bridge(origin: CGPoint(x: 300, y: 200), maxWidth: 200, linkIndex: 6)
            ]
        case 4: // Final bridges
            return (0..<12).map { i in
                let angle = CGFloat(i) * .pi / 6
                return Bridge(
                    origin: CGPoint(x: 250 + cos(angle) * 50, y: 150 + sin(angle) * 50),
                    maxWidth: 150,
                    linkIndex: (i % 6) + 1
                )
            }
        default:
            return []
        }
    }

    private static func createLegendaryHeatPlates(legendIndex: Int) -> [HeatPlate] {
        switch legendIndex {
        case 0:
            return (0..<8).map { i in
                let t = CGFloat(i) / 8.0 * 2 * .pi
                return HeatPlate(
                    position: CGPoint(x: 250 + cos(t) * 180, y: 150 + sin(t) * 100),
                    radius: 18,
                    linkIndex: i + 1
                )
            }
        case 1:
            return [
                HeatPlate(position: CGPoint(x: 250, y: 150), radius: 60, linkIndex: 1),
                HeatPlate(position: CGPoint(x: 100, y: 50), radius: 30, linkIndex: 2),
                HeatPlate(position: CGPoint(x: 400, y: 50), radius: 30, linkIndex: 3),
                HeatPlate(position: CGPoint(x: 100, y: 250), radius: 30, linkIndex: 4),
                HeatPlate(position: CGPoint(x: 400, y: 250), radius: 30, linkIndex: 5)
            ]
        case 2:
            return (0..<15).map { i in
                HeatPlate(
                    position: CGPoint(
                        x: 50 + CGFloat(i % 5) * 100,
                        y: 50 + CGFloat(i / 5) * 100
                    ),
                    radius: 15,
                    linkIndex: (i % 5) + 1
                )
            }
        case 3:
            var plates: [HeatPlate] = []
            for ring in 0..<3 {
                let count = 4 + ring * 2
                for i in 0..<count {
                    let angle = CGFloat(i) * 2 * .pi / CGFloat(count)
                    let radius = 60 + CGFloat(ring * 50)
                    plates.append(HeatPlate(
                        position: CGPoint(x: 250 + cos(angle) * radius, y: 150 + sin(angle) * radius),
                        radius: 20 - CGFloat(ring * 2),
                        linkIndex: ring * 10 + i + 1
                    ))
                }
            }
            return plates
        case 4:
            return [
                HeatPlate(position: CGPoint(x: 250, y: 150), radius: 40, linkIndex: 1),
                HeatPlate(position: CGPoint(x: 50, y: 150), radius: 25, linkIndex: 2),
                HeatPlate(position: CGPoint(x: 450, y: 150), radius: 25, linkIndex: 3),
                HeatPlate(position: CGPoint(x: 250, y: 50), radius: 25, linkIndex: 4),
                HeatPlate(position: CGPoint(x: 250, y: 250), radius: 25, linkIndex: 5),
                HeatPlate(position: CGPoint(x: 125, y: 75), radius: 20, linkIndex: 6),
                HeatPlate(position: CGPoint(x: 375, y: 75), radius: 20, linkIndex: 7),
                HeatPlate(position: CGPoint(x: 125, y: 225), radius: 20, linkIndex: 8),
                HeatPlate(position: CGPoint(x: 375, y: 225), radius: 20, linkIndex: 9)
            ]
        default:
            return []
        }
    }

    private static func createLegendaryIceWalls(legendIndex: Int) -> [IceWall] {
        switch legendIndex {
        case 0: // Infinite loop walls
            return (0..<12).map { i in
                let t = CGFloat(i) / 12.0 * 2 * .pi
                let x = 250 + sin(t) * 150
                let y = 150 + sin(2 * t) * 70
                return IceWall(
                    position: CGPoint(x: x, y: y),
                    size: CGSize(width: 40, height: 40),
                    linkIndex: (i % 4) + 1,
                    meltTime: 10 - Double(i % 3)
                )
            }

        case 1: // Quantum walls
            return [
                // Paired walls that melt together
                IceWall(position: CGPoint(x: 200, y: 100), size: CGSize(width: 100, height: 20), linkIndex: 1, meltTime: 8),
                IceWall(position: CGPoint(x: 300, y: 200), size: CGSize(width: 100, height: 20), linkIndex: 1, meltTime: 8),
                IceWall(position: CGPoint(x: 100, y: 150), size: CGSize(width: 20, height: 100), linkIndex: 2, meltTime: 8),
                IceWall(position: CGPoint(x: 400, y: 150), size: CGSize(width: 20, height: 100), linkIndex: 2, meltTime: 8),
                // Central fortress
                IceWall(position: CGPoint(x: 250, y: 150), size: CGSize(width: 80, height: 80), linkIndex: 3, meltTime: 12)
            ]

        case 2: // Singularity walls
            var walls: [IceWall] = []
            for i in 0..<20 {
                let angle = CGFloat(i) * .pi / 10
                let radius = 200 - CGFloat(i * 8)
                if i % 2 == 0 {
                    walls.append(IceWall(
                        position: CGPoint(x: 250 + cos(angle) * radius, y: 150 + sin(angle) * radius),
                        size: CGSize(width: 30, height: 30),
                        linkIndex: (i / 2) % 5 + 1,
                        meltTime: 5 + Double(i % 3) * 2
                    ))
                }
            }
            return walls

        case 3: // Dimensional walls
            var walls: [IceWall] = []
            // Create 3 layers of reality
            for layer in 0..<3 {
                let alpha = 1.0 - CGFloat(layer) * 0.3
                for i in 0..<4 {
                    walls.append(IceWall(
                        position: CGPoint(
                            x: 100 + CGFloat(i * 100),
                            y: 50 + CGFloat(layer * 75)
                        ),
                        size: CGSize(width: 60, height: 60),
                        linkIndex: layer * 4 + i + 1,
                        meltTime: 6 + Double(layer * 2)
                    ))
                }
            }
            return walls

        case 4: // Final convergence walls
            // Ultimate ice maze
            var walls: [IceWall] = []
            // Outer ring
            for i in 0..<8 {
                let angle = CGFloat(i) * .pi / 4
                walls.append(IceWall(
                    position: CGPoint(x: 250 + cos(angle) * 180, y: 150 + sin(angle) * 130),
                    size: CGSize(width: 50, height: 50),
                    linkIndex: (i % 4) + 1,
                    meltTime: 10
                ))
            }
            // Middle ring
            for i in 0..<6 {
                let angle = CGFloat(i) * .pi / 3
                walls.append(IceWall(
                    position: CGPoint(x: 250 + cos(angle) * 120, y: 150 + sin(angle) * 80),
                    size: CGSize(width: 40, height: 40),
                    linkIndex: (i % 3) + 5,
                    meltTime: 8
                ))
            }
            // Inner core
            walls.append(IceWall(
                position: CGPoint(x: 250, y: 150),
                size: CGSize(width: 60, height: 60),
                linkIndex: 8,
                meltTime: 15
            ))
            return walls

        default:
            return []
        }
    }

    private static func createLegendarySurgeBarriers(legendIndex: Int) -> [SurgeBarrier] {
        switch legendIndex {
        case 0:
            return (0..<4).map { i in
                SurgeBarrier(
                    position: CGPoint(x: 100 + CGFloat(i * 100), y: 200),
                    width: 80,
                    threshold: 0.95 + CGFloat(i) * 0.01
                )
            }
        case 1:
            return [
                SurgeBarrier(position: CGPoint(x: 250, y: 200), width: 400, threshold: 0.9),
                SurgeBarrier(position: CGPoint(x: 250, y: 230), width: 300, threshold: 0.95),
                SurgeBarrier(position: CGPoint(x: 250, y: 260), width: 200, threshold: 1.0)
            ]
        case 2:
            return (0..<6).map { i in
                let angle = CGFloat(i) * .pi / 3
                return SurgeBarrier(
                    position: CGPoint(x: 250 + cos(angle) * 150, y: 200),
                    width: 40,
                    threshold: 1.0
                )
            }
        case 3:
            return [
                SurgeBarrier(position: CGPoint(x: 100, y: 180), width: 100, threshold: 0.98),
                SurgeBarrier(position: CGPoint(x: 250, y: 200), width: 150, threshold: 0.96),
                SurgeBarrier(position: CGPoint(x: 400, y: 220), width: 100, threshold: 0.98)
            ]
        case 4:
            return (0..<8).map { i in
                SurgeBarrier(
                    position: CGPoint(x: 50 + CGFloat(i * 55), y: 200 + sin(CGFloat(i) * .pi / 4) * 30),
                    width: 45,
                    threshold: 0.92 + CGFloat(i) * 0.01
                )
            }
        default:
            return []
        }
    }

    private static func createLegendaryFlowBarriers(legendIndex: Int) -> [FlowBarrier] {
        switch legendIndex {
        case 0:
            return (0..<4).map { i in
                FlowBarrier(
                    position: CGPoint(x: 100 + CGFloat(i * 100), y: 100),
                    width: 80,
                    threshold: 0.95 + CGFloat(i) * 0.01
                )
            }
        case 1:
            return [
                FlowBarrier(position: CGPoint(x: 250, y: 100), width: 400, threshold: 0.9),
                FlowBarrier(position: CGPoint(x: 250, y: 70), width: 300, threshold: 0.95),
                FlowBarrier(position: CGPoint(x: 250, y: 40), width: 200, threshold: 1.0)
            ]
        case 2:
            return (0..<6).map { i in
                let angle = CGFloat(i) * .pi / 3
                return FlowBarrier(
                    position: CGPoint(x: 250 + cos(angle) * 150, y: 100),
                    width: 40,
                    threshold: 1.0
                )
            }
        case 3:
            return [
                FlowBarrier(position: CGPoint(x: 100, y: 120), width: 100, threshold: 0.98),
                FlowBarrier(position: CGPoint(x: 250, y: 100), width: 150, threshold: 0.96),
                FlowBarrier(position: CGPoint(x: 400, y: 80), width: 100, threshold: 0.98)
            ]
        case 4:
            return (0..<8).map { i in
                FlowBarrier(
                    position: CGPoint(x: 50 + CGFloat(i * 55), y: 100 - sin(CGFloat(i) * .pi / 4) * 30),
                    width: 45,
                    threshold: 0.92 + CGFloat(i) * 0.01
                )
            }
        default:
            return []
        }
    }

    private static func createLegendaryResonancePads(legendIndex: Int) -> [ResonancePad] {
        switch legendIndex {
        case 0: // Infinite resonance
            return [
                ResonancePad(position: CGPoint(x: 250, y: 150), radius: 200),
                ResonancePad(position: CGPoint(x: 150, y: 150), radius: 100),
                ResonancePad(position: CGPoint(x: 350, y: 150), radius: 100)
            ]
        case 1: // Quantum resonance
            return (0..<9).map { i in
                ResonancePad(
                    position: CGPoint(x: 150 + CGFloat(i % 3) * 100, y: 50 + CGFloat(i / 3) * 100),
                    radius: 40
                )
            }
        case 2: // Singularity resonance
            return [ResonancePad(position: CGPoint(x: 250, y: 150), radius: 250)]
        case 3: // Dimensional resonance
            return [
                ResonancePad(position: CGPoint(x: 125, y: 75), radius: 60),
                ResonancePad(position: CGPoint(x: 375, y: 75), radius: 60),
                ResonancePad(position: CGPoint(x: 125, y: 225), radius: 60),
                ResonancePad(position: CGPoint(x: 375, y: 225), radius: 60),
                ResonancePad(position: CGPoint(x: 250, y: 150), radius: 80)
            ]
        case 4: // Final resonance
            var pads: [ResonancePad] = []
            for i in 0..<3 {
                for j in 0..<3 {
                    pads.append(ResonancePad(
                        position: CGPoint(x: 150 + CGFloat(i * 100), y: 50 + CGFloat(j * 100)),
                        radius: 35
                    ))
                }
            }
            pads.append(ResonancePad(position: CGPoint(x: 250, y: 150), radius: 180))
            return pads
        default:
            return []
        }
    }

    private static func createLegendaryHazards(legendIndex: Int) -> [Hazard] {
        switch legendIndex {
        case 0: // Infinite hazards
            return [
                Hazard(type: .rotating, position: CGPoint(x: 250, y: 150), size: CGSize(width: 300, height: 200)),
                Hazard(type: .moving, position: CGPoint(x: 100, y: 150), size: CGSize(width: 50, height: 250)),
                Hazard(type: .moving, position: CGPoint(x: 400, y: 150), size: CGSize(width: 50, height: 250))
            ]
        case 1: // Quantum hazards
            return (0..<8).map { i in
                let type: HazardType = i % 2 == 0 ? .electric : .void
                let angle = CGFloat(i) * .pi / 4
                return Hazard(
                    type: type,
                    position: CGPoint(x: 250 + cos(angle) * 150, y: 150 + sin(angle) * 100),
                    size: CGSize(width: 60, height: 60)
                )
            }
        case 2: // Singularity hazard
            return [
                Hazard(type: .rotating, position: CGPoint(x: 250, y: 150), size: CGSize(width: 400, height: 400)),
                Hazard(type: .void, position: CGPoint(x: 250, y: 150), size: CGSize(width: 100, height: 100))
            ]
        case 3: // Dimensional hazards
            return [
                Hazard(type: .moving, position: CGPoint(x: 250, y: 50), size: CGSize(width: 400, height: 30)),
                Hazard(type: .moving, position: CGPoint(x: 250, y: 150), size: CGSize(width: 400, height: 30)),
                Hazard(type: .moving, position: CGPoint(x: 250, y: 250), size: CGSize(width: 400, height: 30)),
                Hazard(type: .electric, position: CGPoint(x: 50, y: 150), size: CGSize(width: 30, height: 200)),
                Hazard(type: .electric, position: CGPoint(x: 450, y: 150), size: CGSize(width: 30, height: 200))
            ]
        case 4: // Final hazards - everything
            return [
                Hazard(type: .rotating, position: CGPoint(x: 250, y: 150), size: CGSize(width: 350, height: 350)),
                Hazard(type: .moving, position: CGPoint(x: 100, y: 100), size: CGSize(width: 80, height: 80)),
                Hazard(type: .moving, position: CGPoint(x: 400, y: 200), size: CGSize(width: 80, height: 80)),
                Hazard(type: .electric, position: CGPoint(x: 250, y: 50), size: CGSize(width: 200, height: 40)),
                Hazard(type: .electric, position: CGPoint(x: 250, y: 250), size: CGSize(width: 200, height: 40)),
                Hazard(type: .void, position: CGPoint(x: 50, y: 50), size: CGSize(width: 60, height: 60)),
                Hazard(type: .void, position: CGPoint(x: 450, y: 50), size: CGSize(width: 60, height: 60)),
                Hazard(type: .void, position: CGPoint(x: 50, y: 250), size: CGSize(width: 60, height: 60)),
                Hazard(type: .void, position: CGPoint(x: 450, y: 250), size: CGSize(width: 60, height: 60))
            ]
        default:
            return []
        }
    }

    private static func createLegendaryCheckpoints(legendIndex: Int) -> [CGPoint] {
        switch legendIndex {
        case 0:
            return [
                CGPoint(x: 100, y: 150), CGPoint(x: 250, y: 150),
                CGPoint(x: 400, y: 150)
            ]
        case 1:
            return [
                CGPoint(x: 150, y: 150), CGPoint(x: 250, y: 50),
                CGPoint(x: 350, y: 150), CGPoint(x: 250, y: 250)
            ]
        case 2:
            return [CGPoint(x: 250, y: 150)]
        case 3:
            return (0..<5).map { i in
                CGPoint(x: 100 + CGFloat(i * 75), y: 150)
            }
        case 4:
            return [
                CGPoint(x: 250, y: 150),
                CGPoint(x: 100, y: 100), CGPoint(x: 400, y: 100),
                CGPoint(x: 100, y: 200), CGPoint(x: 400, y: 200)
            ]
        default:
            return []
        }
    }

    // MARK: - Helper Data

    private static let expertLevelTitles = [
        "Precision Dance", "Windmill Symphony", "Ice Fortress", "Surge Valley",
        "Flow Cascade", "Twin Realms", "Barrier Marathon", "Heat Maze",
        "Resonance Chamber", "Expert's Trial"
    ]

    private static let masterLevelTitles = [
        "Master's Path", "Elemental Fusion", "Time Warp", "Gravity Well",
        "Phase Shift", "Crystal Labyrinth", "Storm Center", "Void Walker",
        "Energy Nexus", "Master's Challenge"
    ]

    private static let extremeLevelTitles = [
        "Extreme Velocity", "Chaos Theory", "Quantum Leap", "Dark Matter",
        "Singularity", "Temporal Flux", "Dimensional Tear", "Event Horizon",
        "Particle Storm", "Extreme Endurance"
    ]

    private static let legendaryLevelTitles = [
        "The Infinite Loop",
        "Quantum Entanglement",
        "The Singularity",
        "Dimensional Rift",
        "The Final Convergence"
    ]

    private static let masterPortalPositions = [
        (spark: CGPoint(x: 450, y: 250), vesper: CGPoint(x: 50, y: 50)),
        (spark: CGPoint(x: 50, y: 250), vesper: CGPoint(x: 450, y: 50)),
        (spark: CGPoint(x: 250, y: 280), vesper: CGPoint(x: 250, y: 20)),
        (spark: CGPoint(x: 480, y: 150), vesper: CGPoint(x: 20, y: 150))
    ]

    private static let extremeStartPositions = [
        (spark: CGPoint(x: 50, y: 250), vesper: CGPoint(x: 450, y: 50)),
        (spark: CGPoint(x: 250, y: 280), vesper: CGPoint(x: 250, y: 20)),
        (spark: CGPoint(x: 20, y: 150), vesper: CGPoint(x: 480, y: 150)),
        (spark: CGPoint(x: 100, y: 100), vesper: CGPoint(x: 400, y: 200)),
        (spark: CGPoint(x: 250, y: 250), vesper: CGPoint(x: 250, y: 50))
    ]

    private static let extremePortalPositions = [
        (spark: CGPoint(x: 450, y: 50), vesper: CGPoint(x: 50, y: 250)),
        (spark: CGPoint(x: 250, y: 20), vesper: CGPoint(x: 250, y: 280)),
        (spark: CGPoint(x: 480, y: 150), vesper: CGPoint(x: 20, y: 150)),
        (spark: CGPoint(x: 400, y: 200), vesper: CGPoint(x: 100, y: 100)),
        (spark: CGPoint(x: 250, y: 150), vesper: CGPoint(x: 250, y: 150))
    ]

    private static let legendaryConfigs = [
        (
            sparkStart: CGPoint(x: 50, y: 150),
            vesperStart: CGPoint(x: 450, y: 150),
            sparkPortal: CGPoint(x: 250, y: 250),
            vesperPortal: CGPoint(x: 250, y: 50)
        ),
        (
            sparkStart: CGPoint(x: 100, y: 100),
            vesperStart: CGPoint(x: 400, y: 200),
            sparkPortal: CGPoint(x: 400, y: 100),
            vesperPortal: CGPoint(x: 100, y: 200)
        ),
        (
            sparkStart: CGPoint(x: 250, y: 280),
            vesperStart: CGPoint(x: 250, y: 20),
            sparkPortal: CGPoint(x: 250, y: 150),
            vesperPortal: CGPoint(x: 250, y: 150)
        ),
        (
            sparkStart: CGPoint(x: 50, y: 50),
            vesperStart: CGPoint(x: 450, y: 250),
            sparkPortal: CGPoint(x: 450, y: 50),
            vesperPortal: CGPoint(x: 50, y: 250)
        ),
        (
            sparkStart: CGPoint(x: 250, y: 250),
            vesperStart: CGPoint(x: 250, y: 50),
            sparkPortal: CGPoint(x: 50, y: 150),
            vesperPortal: CGPoint(x: 450, y: 150)
        )
    ]
}