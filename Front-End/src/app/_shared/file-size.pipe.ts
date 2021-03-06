import {Pipe, PipeTransform} from '@angular/core';

@Pipe(
  {
    name: 'fileSize'
  }
)
export class FileSizePipe implements PipeTransform {
  private units = [
    'bytes',
    'KB',
    'MB',
    'GB',
    'TB',
    'PB'
  ];
  transform(bytes = 0, precision = 2) {
    if (isNaN(parseFloat(String(bytes))) || !isFinite(bytes)) {
      return '?';
    }
    let unit = 0;
    while (bytes > 1024 && unit < this.units.length) {
      bytes /= 1024;
      unit++;
    }
    return bytes.toFixed(precision) + this.units[unit];
  }
}
