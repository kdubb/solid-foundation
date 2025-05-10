#! /usr/bin/env python
import pathlib
import json
import bigint_data
import biguint_data
import bigdecimal_data


generators = [
  bigint_data.generate,
  biguint_data.generate,
  bigdecimal_data.generate
]

if __name__ == "__main__":
  # gather all test files from generators
  test_files = {}
  for generator in generators:
    print(f"Generating {generator.__doc__}...")
    test_files.update(generator())

  # write all test files to Resources folder
  current_dir = pathlib.Path(__file__).parent
  resources_dir = current_dir / "../SolidTests/Resources"
  
  for file_name, test_data in test_files.items():
    file_path = resources_dir / f"{file_name}.json"
    print(f"Writing {file_path.relative_to(current_dir)}...")
    with open(file_path, "w") as f:
      json.dump(test_data, f, indent=2)

  print("Done!")
