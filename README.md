## Imperative steps after installation
### Waltherbox
#### forgejo
* set `service.DISABLE_REGISTRATION` to false
* rebuild
* register admin account through GUI
* copy token Site Administration>Actions>Runners>Create New Runner
* replace token in sops secrets `forgejo-registration-token`

#### Jackett
* Set admin password
* Configure indexers

#### Radarr
* Create admin account
* Setup movies dir
* Connect to jackett

#### Sonarr
* Create admin account
* Setup series dir
* Connect to jackett

#### Jellyfin
* Managed declaratively:) just start library scan
