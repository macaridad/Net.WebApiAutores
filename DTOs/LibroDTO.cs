using System.ComponentModel.DataAnnotations;
using WebApiAutores.Entidades;

namespace WebApiAutores.DTOs
{
    public class LibroDTO
    {
        public int Id { get; set; }
        public string Nombre { get; set; }
        public DateTime FechaPublicacion { get; set; }
        //public List<ComentarioDTO> Comentarios { get; set; }

    }
}
