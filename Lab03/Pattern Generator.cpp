#define _CRT_SECURE_NO_WARNINGS

#include <iostream>
#include <iomanip>
#include <cmath>
#include <string>
#include <string.h>
#include <sstream>
#include <fstream>
#include <vector>
#include <queue>
#include <map>
#include <limits.h>
#include <set>
#include <utility>
#include <algorithm>
#include <ctime>
#include <random>
#include <cstdlib>
#include <time.h>

#define PI atan(1) * 4
#define ll long long int
#define ull unsigned long long
using namespace std;

vector<vector<int>>area(19, vector<int>(19, 0));
ofstream output;
ofstream visualize;
int pattern_num = 500;
bool first_maze = true;


void generate(void)
{
	random_device random_device;
	static constexpr uint32_t wall = 0u;
	static constexpr uint32_t hole = 1u;
	static constexpr uint32_t solution = 2u;
	static constexpr uint8_t north = 0u;
	static constexpr uint8_t south = 1u;
	static constexpr uint8_t west = 2u;
	static constexpr uint8_t east = 3u;

	uint32_t y = 0u;
	uint32_t x = 0u;
	/* The number of the cells, that can be visited. */
	uint32_t total_cells = (area.size() / 2u)*(area[0u].size() / 2u);

	/* Mersenne Twister 19937 pseudo-random generator. */
	std::mt19937 random_generator(random_device());
	/* Random starting point. */
	std::uniform_int_distribution<uint32_t> random_start_y(1u, area.size() - 2u);
	std::uniform_int_distribution<uint32_t> random_start_x(1u, area[0u].size() - 2u);
	/* Random direction. */
	std::uniform_int_distribution<uint32_t> random_dir(north, east);

	/* Make sure, that the two random numbers are odd. */
	y = (random_start_y(random_generator) / 2u * 2u + 1u);
	x = (random_start_x(random_generator) / 2u * 2u + 1u);

	area[y][x] = hole;
	total_cells--;

	/* Loop until there are no cells left. */
	while (total_cells)
	{
		/* Randomly select a direction to move. */
		uint32_t next_cell = random_dir(random_generator);

		if (north == next_cell)
		{
			/* Check if it is possible to go north. */
			if (y >= 3u)
			{
				/* Save the new position. */
				y -= 2;
				/* In case the cell hasn't been visited, then change it to hole and lower the total_cell counter. */
				if (wall == area[y][x])
				{
					total_cells--;
					area[y][x] = hole;
					area[y + 1u][x] = hole;
				}
			}
		}
		else if (south == next_cell)
		{
			/* Check if it is possible to go south. */
			if ((y + 2u) <= area.size() - 2u)
			{
				/* Save the new position. */
				y += 2;
				/* In case the cell hasn't been visited, then change it to hole and lower the total_cell counter. */
				if (wall == area[y][x])
				{
					total_cells--;
					area[y][x] = hole;
					area[y - 1u][x] = hole;
				}
			}
		}
		else if (west == next_cell)
		{
			/* Check if it is possible to go west. */
			if (x >= 3u)
			{
				/* Save the new position. */
				x -= 2;
				/* In case the cell hasn't been visited, then change it to hole and lower the total_cell counter. */
				if (wall == area[y][x])
				{
					total_cells--;
					area[y][x] = hole;
					area[y][x + 1u] = hole;
				}
			}
		}
		else if (east == next_cell)
		{
			/* Check if it is possible to go east. */
			if ((x + 2u) <= area[0u].size() - 2u)
			{
				/* Save the new position. */
				x += 2;
				/* In case the cell hasn't been visited, then change it to hole and lower the total_cell counter. */
				if (wall == area[y][x])
				{
					total_cells--;
					area[y][x] = hole;
					area[y][x - 1u] = hole;
				}
			}
		}
		else
		{
			/* Do nothing. */
		}

	}
	return;
}


bool was_here[19][19];
bool correct_path[19][19];
struct dot {
	int x;
	int y;

};

dot start, destination;
bool recursive_find_path(int x, int y) {

	if (x == destination.x && y == destination.y) {
		correct_path[x][y] = true;
		return true;
	}
	if (area[x][y] == 0 || was_here[x][y]) {
		return false;
	}

	was_here[x][y] = true;

	if (x != 1) {
		if (recursive_find_path(x - 1, y)) {
			correct_path[x][y] = true;
			return true;
		}
	}
	if (y != 1) {
		if (recursive_find_path(x, y - 1)) {
			correct_path[x][y] = true;
			return true;
		}
	}
	if (x != 17) {
		if (recursive_find_path(x + 1, y)) {
			correct_path[x][y] = true;
			return true;
		}
	}
	if (y != 17) {
		if (recursive_find_path(x, y + 1)) {
			correct_path[x][y] = true;
			return true;
		}
	}

	return false;
}



void reset_maze() {
	for (int i = 0; i < 19; i++) {
		for (int j = 0; j < 19; j++) {
			area[i][j] = 0;
		}
	}
	return;
}

int global_hostage_num;
int global_trap_num;

void set_hostage_trap() {

	int hostage_num = rand() % 5;
	int trap_num = rand() % 9;
	global_hostage_num = hostage_num;
	global_trap_num = trap_num;

	while (hostage_num != 0) {
		int x = rand() % 17 + 1;
		int y = rand() % 17 + 1;
		if (!((x == 1 && y == 1) || (x == 17 && y == 17)) && area[x][y] == 1) {
			int tot_walls = 0;
			if (area[x][y - 1] == 0) {
				tot_walls++;
			}
			if (area[x - 1][y] == 0) {
				tot_walls++;
			}
			if (area[x][y + 1] == 0) {
				tot_walls++;
			}
			if (area[x + 1][y] == 0) {
				tot_walls++;
			}

			if (tot_walls == 3) {
				area[x][y] = 3;
				hostage_num--;
			}
		}
	}

	while (trap_num != 0) {
		int x = rand() % 17 + 1;
		int y = rand() % 17 + 1;
		if (!((x == 1 && y == 1) || (x == 17 && y == 17)) && area[x][y] == 1) {
			if (area[x][y - 1] != 2 && area[x - 1][y] != 2 && area[x][y + 1] != 2 && area[x + 1][y] != 2) {
				int tot_walls = 0;
				if (area[x][y - 1] == 0) {
					tot_walls++;
				}
				if (area[x - 1][y] == 0) {
					tot_walls++;
				}
				if (area[x][y + 1] == 0) {
					tot_walls++;
				}
				if (area[x + 1][y] == 0) {
					tot_walls++;
				}
				if (tot_walls == 2) {
					area[x][y] = 2;
					trap_num--;
				}
			}
		}
	}
	return;
}

void print_maze_to_file() {

	if (!first_maze) {
		output << "\n\n";
	}
	else {
		first_maze = false;
	}
	for (int i = 1; i < 18; i++) {
		if (i != 1) {
			output << endl;
		}
		for (int j = 1; j < 18; j++) {
			output << " " << area[i][j];
		}
	}
}

void visualize_maze_to_file() {


	int hostage_num = global_hostage_num;
	int trap_num = global_trap_num;

	visualize << "Maze #" << 500 - pattern_num << endl;
	visualize << "Hostages: " << global_hostage_num << "\n" << "Traps: " << global_trap_num << "\n\n";
	int trap_vio_rule = 0;
	int hostage_vio_rule = 0;
	for (int i = 1; i < 18; i++) {
		if (i != 1) {
			visualize << endl;
		}
		for (int j = 1; j < 18; j++) {


			int tot_walls = 0;
			if (area[i][j - 1] == 0) {
				tot_walls++;
			}
			if (area[i - 1][j] == 0) {
				tot_walls++;
			}
			if (area[i][j + 1] == 0) {
				tot_walls++;
			}
			if (area[i + 1][j] == 0) {
				tot_walls++;
			}


			if (area[i][j] == 0) {
				visualize << '#';
			}
			else if (area[i][j] == 1) {
				visualize << '.';
			}
			else if (area[i][j] == 2) {
				if (area[i][j - 1] == 2 || area[i - 1][j] == 2 || area[i][j + 1] == 2 || area[i + 1][j] == 2) {
					trap_vio_rule = 1;
				}
				if (tot_walls != 2) {

					trap_vio_rule = 2;
				}

				trap_num--;
				visualize << '*';
			}
			else {
				if (tot_walls != 3) {
					hostage_vio_rule = 1;

				}
				hostage_num--;
				visualize << 'h';
			}
		}
	}

	if (trap_num != 0 || hostage_num != 0) {
		visualize << "total trap hostage num not match" << endl;
	}

	if (hostage_vio_rule != 0) {
		visualize << "hostage_vio_rule: " << hostage_vio_rule << endl;
	}
	if (trap_vio_rule != 0) {
		visualize << "trap_vio_rule: " << trap_vio_rule << endl;
	}

	visualize << "\n\n";
	return;
}
//© 2022 GitHub, Inc.
int main() {

	//ofstream output;
	//output.open("output.txt");
	ios_base::sync_with_stdio(false);
	cin.tie(0);


	srand(time(NULL));


	output.open("output.txt");
	visualize.open("visualize.txt");

	while (pattern_num--) {
		generate();
		set_hostage_trap();
		print_maze_to_file();
		visualize_maze_to_file();
		reset_maze();
	}


	output.close();
	visualize.close();

	//output.close();
	return 0;
}