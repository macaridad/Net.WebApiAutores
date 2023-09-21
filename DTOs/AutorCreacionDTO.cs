using System.ComponentModel.DataAnnotations;

namespace WebApiAutores.DTOs
{
    public class AutorCreacionDTO
    {
        [StringLength(maximumLength: 120)]
        public string Nombre { get; set; }
    }
}
