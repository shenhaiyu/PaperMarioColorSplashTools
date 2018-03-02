using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Kontract.Interface;
using Kontract;

namespace MSBTBatch
{
    public class MSBTBatch
    {
        public static ITextAdapter _textAdapter;
        public static List<ITextAdapter> _textAdapters;

        static int Main(string[] args)
        {
            //Console.WriteLine(args.Length);
            if (args.Length != 3){
                Console.WriteLine("Kuriimu MSBT file batch Console tool.");
                Console.WriteLine("Source Code From   IcySon55: https://github.com/IcySon55/Kuriimu");
                Console.WriteLine();
                Console.WriteLine("Modified by shenhaiyu 2018-02-11");
                Console.WriteLine();
                Console.WriteLine("Usage:");
                Console.WriteLine("MSBTBatch cmd1 cmd2 path");
                Console.WriteLine();
                Console.WriteLine("  cmd1:");
                Console.WriteLine("    e ... export *.kup files from *.msbt");
                Console.WriteLine("    i ... import *.kup files to *.msbt");
                Console.WriteLine("  cmd2:");
                Console.WriteLine("    y ... search subdirectories");
                Console.WriteLine("    n ... search top directory only");
                Console.WriteLine("  path:");
                Console.WriteLine("       directory contain *.msbt or *.kup");
                Console.WriteLine();
                Console.WriteLine("  Example: MSBTBatch e n C:\\content\\messages");
                Console.ReadLine();
                return 1;
            }

            _textAdapters = PluginLoader<ITextAdapter>.LoadPlugins("plugins", "text*.dll").ToList();

            int bresult = 1;
            if (args[0].ToLower() == "e" && (args[1].ToLower() == "y" || args[1].ToLower() == "n"))
            {
                bresult = BatchExportKUP(args[2], args[1] == "y");
                //Console.ReadLine();
                return bresult;
            }
            else if (args[0].ToLower() == "i")
            {
                bresult = BatchImportKUP(args[2], args[1] == "y");
                //Console.ReadLine();
                return bresult;
            }
            else
            {
                Console.WriteLine("Command not supported!");
                return 1;
            }
            return 1;
        }

        private static int BatchExportKUP(string path, bool browseSubdirectories)
        {
            int fileCount = 0;
            Console.WriteLine(path);
            if (Directory.Exists(path))
            {
                var types = _textAdapters.Select(x => x.Extension.ToLower()).Select(y => y.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries)).SelectMany(z => z).Distinct().ToList();

                List<string> files = new List<string>();
                foreach (string type in types)
                if (type != "*.kup")
                        files.AddRange(Directory.GetFiles(path, type, browseSubdirectories ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly));

                // TODO: Ask how to handle overwrites and backups
                //Console.WriteLine("{0}", files[0]);

                foreach (string file in files)
                {
                    
                    if (File.Exists(file))
                    {
                        FileInfo fi = new FileInfo(file);
                        ITextAdapter currentAdapter = SelectTextAdapter(_textAdapters, file, true);

                        try
                        {
                            if (currentAdapter != null)
                            {
                                KUP kup = new KUP();

                                currentAdapter.Load(file, true);
                                foreach (TextEntry entry in currentAdapter.Entries)
                                {
                                    Entry kEntry = new Entry();
                                    kEntry.Name = entry.Name;
                                    kEntry.EditedText = entry.EditedText;
                                    kEntry.OriginalText = entry.OriginalText;
                                    kEntry.MaxLength = entry.MaxLength;
                                    kup.Entries.Add(kEntry);

                                    if (currentAdapter.EntriesHaveSubEntries)
                                    {
                                        foreach (TextEntry sub in entry.SubEntries)
                                        {
                                            Entry kSub = new Entry();
                                            kSub.Name = sub.Name;
                                            kSub.EditedText = sub.EditedText;
                                            kSub.OriginalText = sub.OriginalText;
                                            kSub.MaxLength = sub.MaxLength;
                                            kSub.ParentEntry = entry;
                                            kEntry.SubEntries.Add(kSub);
                                        }
                                    }
                                }

                                kup.Save(fi.FullName + ".kup");
                                fileCount++;
                            }
                        }
                        catch (Exception) { }
                    }
                }

                Console.WriteLine(string.Format("Batch export completed successfully. {0} file(s) succesfully exported.", fileCount));
            }

            return 0;
        }

        private static int BatchImportKUP(string path, bool browseSubdirectories)
        {
            int fileCount = 0;
            int importCount = 0;

            if (Directory.Exists(path))
            {
                var types = _textAdapters.Select(x => x.Extension.ToLower()).Select(y => y.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries)).SelectMany(z => z).Distinct().ToList();

                List<string> files = new List<string>();
                foreach (string type in types)
                    if (type != "*.kup")
                        files.AddRange(Directory.GetFiles(path, type, browseSubdirectories ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly));

                foreach (string file in files)
                {
                    if (File.Exists(file))
                    {
                        FileInfo fi = new FileInfo(file);
                        ITextAdapter currentAdapter = SelectTextAdapter(_textAdapters, file, true);
                        try
                        {
                            if (currentAdapter != null && currentAdapter.CanSave && File.Exists(fi.FullName + ".kup"))
                            {
                                KUP kup = KUP.Load(fi.FullName + ".kup");

                                currentAdapter.Load(file, true);
                                foreach (TextEntry entry in currentAdapter.Entries)
                                {
                                    Entry kEntry = kup.Entries.Find(o => o.Name == entry.Name);

                                    if (kEntry != null)
                                        entry.EditedText = kEntry.EditedText;

                                    if (currentAdapter.EntriesHaveSubEntries && kEntry != null)
                                    {
                                        foreach (TextEntry sub in entry.SubEntries)
                                        {
                                            Entry kSub = (Entry)kEntry.SubEntries.Find(o => o.Name == sub.Name);

                                            if (kSub != null)
                                                sub.EditedText = kSub.EditedText;
                                        }
                                    }
                                }

                                currentAdapter.Save();
                                importCount++;
                            }

                            fileCount++;
                        }
                        catch (Exception) { }
                    }
                }
                Console.WriteLine(string.Format("Batch import completed successfully. {0} of {1} files succesfully imported.", importCount, fileCount));
            }

            return 0;
        }
        public static ITextAdapter SelectTextAdapter(List<ITextAdapter> textAdapters, string filename, bool batchMode = false)
        {
            ITextAdapter result = null;

            // first look for adapters whose extension matches that of our filename
            List<ITextAdapter> matchingAdapters = textAdapters.Where(adapter => adapter.Extension.TrimEnd(';').Split(';').Any(s => filename.ToLower().EndsWith(s.TrimStart('*')))).ToList();

            result = matchingAdapters.FirstOrDefault(adapter => adapter.Identify(filename));

            // if none of them match, then stry all other adapters
            if (result == null)
                result = textAdapters.Except(matchingAdapters).FirstOrDefault(adapter => adapter.Identify(filename));

            if (result == null && !batchMode)
                Console.WriteLine("None of the installed plugins are able to open the file.");
            return result;
        }
    }
}
