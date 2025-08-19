import os
import sys
import time
import shutil
import zstandard as zstd
from concurrent.futures import ThreadPoolExecutor

# Compression constants
MAGIC_NUMBER = b'\x28\xB5\x2F\xFD'
DICT_START_HEX = bytes.fromhex("37 A4 30 EC")
MAX_COMPRESSION_LEVEL = 22
MAX_WORKERS = 4

# These will be set dynamically
ORIGINAL_ZSDIC_PAK = ""
UNPACK_DIR = ""
EDITED_DAT_DIR = ""
REPACKED_DIR = ""
REPACKED_PAK = ""

def ask_paths():
    print("Enter the following paths (use double backslashes or raw string format):\n")

    pak_folder = input("1. Folder containing original .pak file: ").strip()
    pak_file = os.path.join(pak_folder, "mini_obbzsdic_obb.pak")

    unpack_dir = input("2. Output folder for unpacked segments: ").strip()
    edited_dat_dir = input("3. Folder with edited .dat files: ").strip()
    repacked_dir = input("4. Output folder for repacked .pak: ").strip()
    repacked_pak = os.path.join(repacked_dir, "mini_obbzsdic_obb.pak")

    return pak_file, unpack_dir, edited_dat_dir, repacked_dir, repacked_pak

def extract_dictionary(pak_file, start_hex):
    with open(pak_file, 'rb') as f:
        data = f.read()
    start = data.find(start_hex)
    if start == -1:
        raise ValueError("Dictionary start not found.")
    return data[start:]

def split_segments(data, magic_number):
    indices = []
    start = 0
    while (start := data.find(magic_number, start)) != -1:
        indices.append(start)
        start += len(magic_number)
    indices.append(len(data))
    return [(i + 1, data[indices[i]:indices[i + 1]]) for i in range(len(indices) - 1)]

def decompress_segment(segment, dictionary, output_dir):
    index, data = segment
    try:
        dctx = zstd.ZstdDecompressor(dict_data=dictionary)
        decompressed = dctx.decompress(data)
        output_path = os.path.join(output_dir, f'{index:08d}.dat')
        with open(output_path, 'wb') as f:
            f.write(decompressed)
        return f"{index}.dat extracted."
    except Exception as e:
        return f"{index}.dat error: {e}"

def extract_segment(pak_file, segment_index, magic_number):
    with open(pak_file, 'rb') as f:
        data = f.read()
    indices = []
    start = 0
    while (start := data.find(magic_number, start)) != -1:
        indices.append(start)
        start += len(magic_number)
    indices.append(len(data))
    if not (1 <= segment_index <= len(indices) - 1):
        raise IndexError("Invalid segment index.")
    return indices[segment_index - 1], indices[segment_index], data[indices[segment_index - 1]:indices[segment_index]]

def compress_file(input_file, dict_data, level):
    dictionary = zstd.ZstdCompressionDict(dict_data)
    cctx = zstd.ZstdCompressor(dict_data=dictionary, level=level)
    with open(input_file, 'rb') as f:
        return cctx.compress(f.read())

def replace_segment(pak_file, start, end, compressed_data):
    with open(pak_file, 'rb+') as f:
        f.seek(start)
        f.write(compressed_data)
        f.write(b'\x00' * (end - start - len(compressed_data)))

def unpack_zsdic():
    if not os.path.exists(ORIGINAL_ZSDIC_PAK):
        print("PAK file not found.")
        return
    os.makedirs(UNPACK_DIR, exist_ok=True)
    with open(ORIGINAL_ZSDIC_PAK, 'rb') as f:
        data = f.read()
    dict_data = extract_dictionary(ORIGINAL_ZSDIC_PAK, DICT_START_HEX)
    dictionary = zstd.ZstdCompressionDict(dict_data)
    segments = split_segments(data, MAGIC_NUMBER)
    print(f"{len(segments)} segments found. Extracting...")

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        for result in executor.map(lambda s: decompress_segment(s, dictionary, UNPACK_DIR), segments):
            print(result)

    print("All segments extracted successfully.")
    input("Press Enter to return to menu...")

def repack_zsdic():
    if not os.path.exists(ORIGINAL_ZSDIC_PAK):
        print("Original PAK file is missing.")
        return
    os.makedirs(REPACKED_DIR, exist_ok=True)
    shutil.copy2(ORIGINAL_ZSDIC_PAK, REPACKED_PAK)
    dict_data = extract_dictionary(ORIGINAL_ZSDIC_PAK, DICT_START_HEX)
    for file in os.listdir(EDITED_DAT_DIR):
        if not file.endswith('.dat'):
            continue
        try:
            seq = int(file.split('.')[0])
            input_path = os.path.join(EDITED_DAT_DIR, file)
            start, end, _ = extract_segment(REPACKED_PAK, seq, MAGIC_NUMBER)
            for level in range(1, MAX_COMPRESSION_LEVEL + 1):
                try:
                    compressed = compress_file(input_path, dict_data, level)
                    replace_segment(REPACKED_PAK, start, end, compressed)
                    print(f"{file} repacked successfully.")
                    break
                except ValueError:
                    continue
            else:
                print(f"{file} could not be repacked.")
        except Exception as e:
            print(f"{file} error: {e}")
    input("Press Enter to return to menu...")

def main_menu():
    global ORIGINAL_ZSDIC_PAK, UNPACK_DIR, EDITED_DAT_DIR, REPACKED_DIR, REPACKED_PAK
    (ORIGINAL_ZSDIC_PAK,
     UNPACK_DIR,
     EDITED_DAT_DIR,
     REPACKED_DIR,
     REPACKED_PAK) = ask_paths()

    while True:
        os.system('cls' if os.name == 'nt' else 'clear')
        header_color = '\033[96m'
        option_color = '\033[93m'
        reset_color = '\033[0m'
        print(f"{reset_color}{'=' * 100}")
        print(f"{header_color}          PUBG RPAD TOOL LITE/MOBILE - v1.0{reset_color}")
        print(f"{header_color}                TURKISH DEVELOPER{reset_color}")
        print(f"{header_color}               TELEGRAM @RpadCourse{reset_color}")
        print(f"{reset_color}{'=' * 100}\n")
        print(f"{option_color}   [1] Unpack ZSDIC PAK{reset_color}")
        print(f"{option_color}   [2] Repack ZSDIC PAK{reset_color}")
        print(f"{option_color}   [3] Delete Unpacked Folder{reset_color}")
        print(f"{option_color}   [4] Exit{reset_color}")
        print(f"\n{reset_color}{'=' * 100}\n")

        choice = input("Enter your choice: ").strip()
        if choice == '1':
            unpack_zsdic()
        elif choice == '2':
            repack_zsdic()
        elif choice == '3':
            shutil.rmtree(UNPACK_DIR, ignore_errors=True)
            print("Unpacked folder deleted.")
            input("Press Enter to return to menu...")
        elif choice == '4':
            print("Exiting...")
            break
        else:
            print("Invalid choice. Please try again.")
            time.sleep(1)

if __name__ == "__main__":
    main_menu()
