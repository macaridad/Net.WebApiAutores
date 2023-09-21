using System.ComponentModel.DataAnnotations;

namespace WebApiAutores.Entidades
{
    public class Autor
    {

        //properties
        public int Id { get; set; }
        [StringLength(maximumLength: 120)]
        public string Nombre { get; set; }
        public List<AutorLibro> AutoresLibros { get; set; }

        //métodos de comportamiento 

    }
}
