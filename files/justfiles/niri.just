# Copyright 2026 Mr. Grizzl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

sessionUserHome := env('HOME')

# Update DMS Greeter theme (reflecting current user theme)
update-greeter-theme:
    #! /bin/run0 /bin/bash

    set -euo pipefail

    ##
    dmsGreeterSysFolder='/var/cache/dms-greeter'
    dmsUserSettingsFile='{{ sessionUserHome }}/.config/DankMaterialShell/settings.json'
    dmsUserSessionFile='{{ sessionUserHome }}/.local/state/DankMaterialShell/session.json'
    dmsCustomThemeFile=$(jq -r '.customThemeFile' ${dmsUserSettingsFile})
    dmsCustomWallpaper=$(jq -r '.wallpaperPath' ${dmsUserSessionFile})

    ## Settings JSON
    jq --argjson use24HourClock $(jq '.use24HourClock' ${dmsUserSettingsFile}) \
       --argjson showSeconds $(jq '.showSeconds' ${dmsUserSettingsFile}) \
       --arg lockDateFormat "" \
       --argjson lockScreenShowPowerActions $(jq '.lockScreenShowPowerActions' ${dmsUserSettingsFile}) \
       --argjson useFahrenheit $(jq '.useFahrenheit' ${dmsUserSettingsFile}) \
       --arg weatherLocation "$(jq -r '.weatherLocation' ${dmsUserSessionFile})" \
       --arg weatherCoordinates "$(jq -r '.weatherCoordinates' ${dmsUserSessionFile})" \
       --argjson useAutoLocation $(jq '.useAutoLocation' ${dmsUserSettingsFile}) \
       --argjson weatherEnabled $(jq '.weatherEnabled' ${dmsUserSettingsFile}) \
       --arg currentThemeName "$(jq -r '.currentThemeName' ${dmsUserSettingsFile})" \
       --arg customThemeFile "${dmsGreeterSysFolder}/theme.json" \
       --arg matugenScheme "$(jq -r '.matugenScheme' ${dmsUserSettingsFile})" \
       --argjson nightModeEnabled $(jq '.nightModeEnabled' ${dmsUserSettingsFile}) \
       --arg iconTheme "$(jq -r '.iconTheme' ${dmsUserSettingsFile})" \
       --arg fontFamily "$(jq -r '.fontFamily' ${dmsUserSettingsFile})" \
       --argjson fontWeight $(jq '.fontWeight' ${dmsUserSettingsFile}) \
       --argjson fontScale $(jq '.fontScale' ${dmsUserSettingsFile}) \
       --argjson cornerRadius $(jq '.cornerRadius' ${dmsUserSettingsFile}) \
       --arg widgetBackgroundColor "$(jq -r '.widgetBackgroundColor' ${dmsUserSettingsFile})" \
       --arg surfaceBase "s" \
       --argjson animationSpeed $(jq '.animationSpeed' ${dmsUserSettingsFile}) \
       -n '
       {
         use24HourClock: $use24HourClock,
         showSeconds: $showSeconds,
         lockDateFormat: $lockDateFormat,
         lockScreenShowPowerActions: $lockScreenShowPowerActions,
         useFahrenheit: $useFahrenheit,
         weatherLocation: $weatherLocation,
         weatherCoordinates: $weatherCoordinates,
         useAutoLocation: $useAutoLocation,
         weatherEnabled: $weatherEnabled,
         currentThemeName: $currentThemeName,
         customThemeFile: $customThemeFile,
         matugenScheme: $matugenScheme,
         nightModeEnabled: $nightModeEnabled,
         iconTheme: $iconTheme,
         fontFamily: $fontFamily,
         fontWeight: $fontWeight,
         fontScale: $fontScale,
         cornerRadius: $cornerRadius,
         widgetBackgroundColor: $widgetBackgroundColor,
         surfaceBase: $surfaceBase,
         animationSpeed: $animationSpeed
       }' \
       > ${dmsGreeterSysFolder}/settings.json

    ## Session JSON
    jq --arg wallpaperPath "${dmsGreeterSysFolder}/wallpaper.${dmsCustomWallpaper##*/}" \
       -n '
       {
         wallpaperPath: $wallpaperPath
       }' \
       > ${dmsGreeterSysFolder}/session.json

    rm ${dmsGreeterSysFolder}/theme.json ${dmsGreeterSysFolder}/wallpaper.*

    cp ${dmsCustomThemeFile} ${dmsGreeterSysFolder}/theme.json
    cp ${dmsCustomWallpaper} ${dmsGreeterSysFolder}/wallpaper.${dmsCustomWallpaper##*/}

    chown greeter:greeter /var/cache/dms-greeter/*

    echo "DMS Greeter theme updated."
