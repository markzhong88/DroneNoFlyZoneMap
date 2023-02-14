# Drone No Fly Zone Map

This is a stripped version of the No Fly Zone Map from Drone Buddy App iOS version. The map is designed to help drone pilots identify areas where they are restricted from flying. This open source project provides the map as a standalone component that can be integrated into other drone-related applications. The no fly zone data displayed on the map is obtained from a combination of sources, including:

- World-wide airport data from https://ourairports.com/data/
- US National park boundary data from https://public-nps.opendata.arcgis.com/maps/c8d60ffcbf5c4030a17762fe10e81c6a/about
- FAA flight restriction data from https://udds-faa.opendata.arcgis.com
- UK National Park data from https://naturalengland-defra.opendata.arcgis.com/datasets/d333c7529754444894e2d7f5044d1bbf_0/explore?location=52.943317%2C-1.215643%2C7.77
- Canada National Park data from https://hub.arcgis.com/datasets/dd8cd91871534c9aa34310eed84fe076/explore

![IMG_6723 2](https://user-images.githubusercontent.com/20956156/218617491-378600ff-84a9-4320-b313-78e43c734996.PNG)

## Getting Started

These instructions will help you get the No Fly Zone Map up and running in your development environment.

### Prerequisites

Before you begin, you will need the following:

- iOS development environment
- Xcode
- CocoaPods
- Mapbox API key

### Installing

1. Clone the repository to your local machine:

2. Navigate to the project directory:

3. Install the project dependencies using CocoaPods:
$ pod install

4. Replace the `<MAPBOX_API_KEY>` placeholder in the `Info.plist` file MGLMapboxAccessToken with your own Mapbox API key:

5. Open the project in Xcode:

6. Build and run the project.

## Data Format

The No Fly Zone Map uses geojson data format to display the no fly zones on the map. If the dataset is too large, you can use Mapshaper to reduce its size. https://mapshaper.org

## Usage

The No Fly Zone Map can be integrated into your drone-related application by customizing the map and data.


## Contributing

We welcome contributions to this project! If you find a bug, have a suggestion for a new feature, or just want to help out, please feel free to submit a pull request.

## License

This project is licensed under the MIT License.

## Acknowledgements

This project is based on the No Fly Zone Map from the "Drone Buddy" app. Check out the app at https://dronebuddy.io
