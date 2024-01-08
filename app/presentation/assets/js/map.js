document.addEventListener('DOMContentLoaded', function() {
  // Get the map element
  const mapElement = document.getElementById('map');

  // Retrieve the data attribute
  const locationData = JSON.parse(mapElement.dataset.location);

  // Now you can use the locationData in your JavaScript
  console.log(locationData);

  initMap(locationData);
  // Initialize your map or do other operations with the data
});


async function initMap(locationData) {
  console.log(locationData);
  // Request needed libraries.
  const { Map, InfoWindow } = await google.maps.importLibrary("maps");

  const map = new Map(document.getElementById("map"), {
    zoom: 12,
    center: { lat: locationData[0].latitude, lng: locationData[0].longitude },
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });


  // Initial size of the marker icon
  const initialSize = new google.maps.Size(35, 35);
  

  locationData.forEach((stop, i) => {
    console.log(stop);
    const marker = new google.maps.Marker({
      position: {lat:stop.latitude, lng:stop.longitude},
      map,
      icon: {
        url: 'https://soapicture.s3.ap-northeast-2.amazonaws.com/uploadsspec/test_s3_upload_image/veterinarian.png',
        anchor: new google.maps.Point(0, 0),
        scaledSize: initialSize,
      },
      title: `${i + 1}. ${stop.name}`,
      content: `
        <div>Address: ${stop.address}</div>
        <div>Open Time: open now? ${stop.open_time}</div>
        <div>Rating: ${stop.rating} (${stop.total_ratings} ratings)</div>
        <div>Road: ${stop.which_road}</div>
      `,
    });
  
    // Add a click event listener to display the title and content with newline when the marker is clicked
    google.maps.event.addListener(marker, 'click', function () {
      const infoWindow = new google.maps.InfoWindow({
        content:`<div><strong>${marker.title}</strong></div><div>${marker.content.replace(/\n/g, '<br>')}</div>`,
      });
      infoWindow.open(map, marker);
    });

    google.maps.event.addListener(map, 'zoom_changed', function () {
      // Get the current zoom level
      const zoomLevel = map.getZoom();
      
    
      // Calculate the new size based on the zoom level
      const newWidth = initialSize.width * zoomLevel;
      const newHeight = initialSize.height * zoomLevel;
    
      // Update the scaledSize property of the marker's icon
      marker.setIcon({
        ...marker.getIcon(),
        scaledSize: new google.maps.Size(newWidth, newHeight),
      });
    });
  });
}