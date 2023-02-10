Function Test-DockerImagePresence {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ComposeFile
    )

    # Read the contents of the docker-compose.yaml file
    $compose = Get-Content $ComposeFile

    # Extract the list of image names from the compose file
    $images = Select-String -InputObject $compose -Pattern 'image: ([a-zA-Z0-9/._-]+):' | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Groups | Select-Object -ExpandProperty Value

    # Check if each image is present in the machine
    $missingImages = @()
    foreach ($image in $images) {
        try {
            docker inspect $image
        } catch {
            $missingImages += $image
        }
    }

    # If any images are missing, prompt the user to pull them
    if ($missingImages.Count -gt 0) {
        Write-Host "The following images are missing from the machine: $($missingImages -join ', ')"
        Write-Host "Do you want to pull these images? (y/n)"
        $answer = Read-Host
        if ($answer -eq "y") {
            docker-compose -f $ComposeFile pull
            Write-Host "Images pulled successfully."
        }
    } else {
        # Output a message if all images were found
        Write-Host "All necessary images are present in the machine."
    }
}

# Check if Docker is installed
if (!(Get-Command docker)) {
    # Docker is not installed
    Write-Host "Docker is not installed on this system."
    Write-Host "Please follow the instructions to install Docker Desktop: www.docker.com"
    Exit
}

# Check if the targets.json file already exists
if (Test-Path $PWD/config/prometheus/targets.json) {
    Write-Host "The file targets.json already exists. Do you want to overwrite it? (y/n)"
    $answer = Read-Host
    if ($answer -eq "y") {
        # Prompt the user for the target information
        $targets = @()
        $addAnother = $true
        while ($addAnother) {
            $target = @{}
            $target.targets = Read-Host -Prompt "Enter the target IP address (e.g. 10.0.0.1):"
            $target.labels = @{}
            $target.labels.hostname = Read-Host -Prompt "Enter the target hostname:"

            # Add the target to the list of targets
            $targets += $target

            Write-Host "Do you want to add another target? (y/n)"
            $answer = Read-Host
            if ($answer -ne "y") {
                $addAnother = $false
            }
        }
    }
}


# Convert the targets to JSON and save it to the targets.json file
$json = $targets | ConvertTo-Json -Depth 5
Set-Content -Path  $PWD/config/prometheus/targets.json -Value $json -Encoding UTF8

# Output a message to confirm the file was saved
Write-Host "The JSON object was saved to $PWD/config/prometheus/targets.json"

# Check if the necessary images are present in the machine
Write-Host "Checking if the necessary images are present in the machine..."
Test-DockerImagePresence -ComposeFile $PWD/docker-compose.yml

Write-Host "Do you want to start the Prometheus stack? (y/n)"
$answer = Read-Host
if ($answer -eq "y") {
    Write-Host "Starting the Prometheus stack, please wait..."
    Write-Host "The Prometheus stack has been started."
    Write-Host "You will can access the Prometheus UI at http://localhost:9090"
    Write-Host "You will can access the Grafana UI at http://localhost:3000 with the username 'admin' and the password 'admin'"
    docker-compose -f $PWD/docker-compose.yml up
} else {
    Write-Host "The Prometheus stack was not started."
}
