package main

import "core:fmt"
import "core:testing"
import "core:math/linalg/glsl"


@(test)
test :: proc(t: ^testing.T) {

		m1 := mat4{
				1, 1, 1, 1,
				1, 1, 1, 1,
				1, 1, 1, 1,
				1, 1, 1, 1
			}
	i := glsl.identity(glsl.mat4)
	fmt.println(&i[0,0])
	fmt.println(&m1[0,0])
}

@(test)
test2 :: proc(t: ^testing.T) {
	x := entity{
		hp = 5,
		dmg = 1
	}
	
	y := a(x)

	testing.expect(t, x.hp == 5)
	testing.expect(t, y.hp == 4)
}

entity :: struct {
	hp: int,
	dmg: int
}

@(test)
test3 :: proc(t: ^testing.T) {
	x := entity{
		hp = 5,
		dmg = 1
	}
	
	y := b(&x)

	testing.expect(t, x.hp == 5)
	testing.expect(t, y.hp == 4)
}

a :: proc(x: entity) -> entity {
	y := x
	y.hp -= x.dmg
	return y
}

b :: proc(x: ^entity ) -> entity {
	x.hp -= x.dmg 
	return x^
}
