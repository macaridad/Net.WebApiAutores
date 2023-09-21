using System.ComponentModel.DataAnnotations;

namespace WebApiAutores.DTOs
{
    public class LibroCreacionDTO
    {
        [StringLength(maximumLength: 250)]
        public string Nombre { get; set; }
        public List<int> AutoresIds { get; set; }
        public DateTime FechaPublicacion { get; set; }
    }
}
