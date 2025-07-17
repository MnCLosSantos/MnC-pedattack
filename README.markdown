---------------------------------------------------------------------------------------------------------------------

#                                                  MnC-PedAttack

---------------------------------------------------------------------------------------------------------------------

<img width="1024" height="1024" alt="459189577-99393c2d-0c23-4c4d-88a9-13414b6d8b78" src="https://github.com/user-attachments/assets/c68a11ab-35c2-49c2-b9fc-57fe48368dfb" />

---------------------------------------------------------------------------------------------------------------------

## **MnC-PedAttack** is a FiveM resource that allows server administrators to initiate a gang attack on a specific player, spawning hostile NPCs to engage the target. This resource is designed for GTA V servers running the QBCore framework, providing an immersive and dynamic gameplay experience.

---------------------------------------------------------------------------------------------------------------------


![1](https://github.com/user-attachments/assets/301b2406-b815-45dd-a281-b6a857aa6ef8)
![2](https://github.com/user-attachments/assets/428070d9-134b-44f1-b5db-391d0b176c5a)
![3](https://github.com/user-attachments/assets/0d6072c1-84eb-444e-a353-716e3faa38ba)


---------------------------------------------------------------------------------------------------------------------
## Features
- **Targeted NPC Attacks**: Spawn a configurable number of hostile NPCs to attack a specified player.
- **Customizable Settings**: Adjust spawn radius, despawn time, and NPC behavior via client file.
- **Relationship Management**: NPCs are grouped to avoid infighting and focus solely on the target player.
- **Automatic Cleanup**: NPCs and vehicles are despawned after a set time or when the target dies/leaves.
- **Notification System**: Uses `ox_lib` for user-friendly notifications to admins and players.
- **Server-Side Control**: Commands restricted to authorized users for secure operation.
---------------------------------------------------------------------------------------------------------------------
## Requirements
- **QBCore/QBOX** framework.
- **ox_lib** for notifications.
---------------------------------------------------------------------------------------------------------------------
## Installation

1. **Download the Resource**:
   Clone or download the repository to your FiveM server's `resources` directory:
   ```bash
   git clone https://github.com/MnCLosSantos/MnC-pedattack.git [server-data]/resources/[custom]/MnC-pedattack
   ```

2. **Add to Server Configuration**:
   Ensure the resource is loaded by adding it to your `server.cfg`:
   ```cfg
   ensure MnC-pedattack
   ```

3. **Install Dependencies**:
   Ensure `ox_lib` is installed and running on your server. Download it from [ox_lib GitHub](https://github.com/overextended/ox_lib) if needed.

4. **Restart Server**:
   Restart your FiveM server or use the `refresh` and `start MnC-pedattack` commands in the server console.
---------------------------------------------------------------------------------------------------------------------
## Usage

1. **Start an Attack**:
   Use the `/pedattack <playerID>` command to spawn hostile NPCs targeting a specific player.
   Example:
   ```bash
   /pedattack 2
   ```

2. **Stop an Attack**:
   Use the `/stoppedattack` command to terminate the attack and clean up all spawned NPCs.
   Example:
   ```bash
   /stoppedattack
   ```

3. **Automatic Cleanup**:
   - Attacks automatically stop if the target player dies or disconnects.
   - NPCs despawn after the configured `DespawnTime` (default: 5 minutes).
---------------------------------------------------------------------------------------------------------------------
## Configuration

The configuration is located in `client.lua` and can be modified to suit your server's needs. Key settings include:

```lua
local Config = {
    DespawnTime = 5 * 60 * 1000, -- Time before NPCs despawn (5 minutes)
    SpawnCountPerGang = 80,      -- Number of NPCs to spawn
    VehicleSeats = 4,            -- Unused in current version
    PedSpawnWait = 200,          -- Delay between NPC spawns (ms)
    VehicleSpawnWait = 200,      -- Unused in current version
    SpawnRadius = 660,           -- Maximum spawn distance from target
    MinSpawnDistance = 50        -- Minimum spawn distance from target
}
```

To customize, edit the `Config` table in `client.lua`. Future versions may move this to a separate `config.lua` file for easier management.
---------------------------------------------------------------------------------------------------------------------
## Commands

| Command          | Description                              | Permission   |
|------------------|------------------------------------------|--------------|
| `/pedattack <id>`| Start a gang attack on the specified player ID | Admin only   |
| `/stoppedattack` | Stop the active gang attack and clean up | Admin only   |

**Note**: Commands are restricted to users with appropriate permissions (configured via your server's ACE permissions or QBCore admin roles).
---------------------------------------------------------------------------------------------------------------------
## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Make your changes and commit (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

Please ensure your code follows the existing style and includes appropriate comments. See [CONTRIBUTING.md](CONTRIBUTING.md) for more details (to be added).
---------------------------------------------------------------------------------------------------------------------
## Contact

For issues, suggestions, or questions, please:
- Open an issue on [GitHub](https://github.com/MnCLosSantos/MnC-pedattack/issues).
- Contact the maintainer: [MnCLosSantos](https://github.com/MnCLosSantos).

---
---------------------------------------------------------------------------------------------------------------------
Thank you for using **MnC-PedAttack**! We hope this resource enhances your FiveM server's gameplay.
---------------------------------------------------------------------------------------------------------------------
