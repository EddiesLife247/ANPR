let Config = { DebugMode: true }; // Default Config, will be updated from server

document.addEventListener("DOMContentLoaded", function () {
    document.body.style.backgroundColor = "transparent"; // Set default transparency on load

    document.getElementById("addBolo").addEventListener("click", function () {
        if (Config.DebugMode) console.log("User clicked Add BOLO button");

        // Show the Add BOLO form
        let div = document.getElementById("addBoloForm");
        if (div) {
            console.log("Found the addBoloForm element.");
            div.style.display = "flex"; // Use flex instead of block for better centering
        } else {
            console.error("Error: addBoloForm element not found!");
        }
    });

    document.getElementById("closeBolo").addEventListener("click", function () {
        if (Config.DebugMode) console.log("User clicked Close BOLO button");
        document.querySelector(".container").style.display = "none"; // Ensure the UI is hidden
        document.getElementById("addBoloForm").style.display = "none"; // Hide the add BOLO form if open
        document.body.style.backgroundColor = "transparent"; // Remove the dark background
        fetch("https://anpr/close", {
            method: "POST"
        }).catch(err => console.error("Error triggering close callback:", err));
    });

    document.getElementById("cancelBolo").addEventListener("click", function () {
        let form = document.getElementById("addBoloForm");
        if (form) {
            form.style.display = "none"; // Hide the form
        }
    });

    document.getElementById("boloForm").addEventListener("submit", function (event) {
        event.preventDefault(); // Prevent actual form submission

        // Retrieve the values from the input fields
        let plate = document.getElementById("boloPlate").value;
        let reason = document.getElementById("boloReason").value;

        // Check if all fields are filled in
        if (!plate || !reason) {
            alert("Please fill in all fields!");
            return;
        }

        // Prepare the data to be sent
        let boloData = { plate: plate, reason: reason };

        // Send the data to the server using fetch
        fetch(`https://${GetParentResourceName()}/bolo:add`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(boloData)
        }).then(response => {
            if (!response.ok) {
                throw new Error("Server responded with status " + response.status);
            }
            return response.json();
        }).then(data => {
            console.log("BOLO added successfully:", data);
            document.getElementById("addBoloForm").style.display = "none"; // Hide form after submission
        }).catch(err => console.error("Error sending request to add BOLO:", err));
    });
});

function removeBolo(plate) {
    fetch(`https://anpr/bolo:remove`, {
        method: 'POST',
        body: JSON.stringify({ plate: plate })
    }).then(response => response.json())
        .then(data => {
            if (data.success) {
                alert("BOLO removed successfully.");
            } else {
                alert("Error removing BOLO.");
            }
        });
}
// Handle received NUI data
window.addEventListener("message", function (event) {
    if (event.data.type === "removeBolo") {
        const plate = event.data.plate;
        const rows = document.querySelectorAll('#boloTable tr');
        rows.forEach(row => {
            if (row.querySelector('td') && row.querySelector('td').textContent === plate) {
                row.remove(); // Remove the row from the table
            }
        });
    }
    if (event.data.action === 'openBoloMenu') {
        console.log("Received BOLO data:", event.data.data);  // Log BOLO data received from the server

        let bolos = event.data.data;

        // Ensure the NUI body is shown
        document.body.style.display = 'block';
        document.querySelector(".container").style.display = "block";


        let tableBody = document.getElementById("boloTable").getElementsByTagName("tbody")[0];
        tableBody.innerHTML = "";  // Clear previous rows

        if (bolos.length === 0) {
            console.log("No active BOLOs");
            let row = tableBody.insertRow();
            let cell = row.insertCell();
            cell.colSpan = 4;
            cell.textContent = "No active BOLOs";
            cell.style.textAlign = "center";
        } else {
            bolos.forEach(function (bolo) {
                let row = tableBody.insertRow();
                row.insertCell().textContent = bolo.plate;
                row.insertCell().textContent = bolo.officer;
                row.insertCell().textContent = bolo.reason;
                row.insertCell().textContent = bolo.expires;

                // Optional: Add Remove button if needed
            });
        }
    }
});