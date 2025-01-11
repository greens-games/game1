### Rendering

### Textures


### Transformations
- End goal is to feed a matrix as a uniform into our vertex shader
- Before feeding this in we apply the relevant transformations to an identity matrix
- Then multiply the position vector in the Shader to the Transformation Matrix
- We can proably replace glm calls with linalg, this may or may not be better performance

