# Dogmode Example

- [Introduction](#introduction)

## Introduction

The dog mode example will be migrated to this repository component-by-component. The description
below represents the overall example when it is finished.

The dog mode allows a car owner to keep their dog safe while they are away from the car. If the
ambient temperature is high, multiple different applications will interact with each other to
ensure that the temperature inside the car is at a safe level for the dog. This works as follows:
first, the dog mode logic application detects whether a dog is present, either by automatically
connecting a camera with object detection, or through user interaction in the UI application. If a
dog is detected, it will monitor various vehicle hardware properties through the Vehicle
Abstraction Service (VAS). Based on certain conditions, actions are taken. For example, if the
battery is low, the owner is notified to return to the car immediately. If the temperature rises,
the air conditioning is turned on.
